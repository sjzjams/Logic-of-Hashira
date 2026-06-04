# JNI/FFI Bridge Guidelines

Guidelines for efficient and safe data passing between Dart and Native code (C++/Kotlin/Swift).

---

## Scenario: Native Result Passing

### 1. Scope / Trigger
- Trigger: Implementing or modifying a `MethodChannel` or `FFI` call that returns data from native to Dart.

### 2. Signatures
- C++: `jstring Java_com_..._nativeSegment(JNIEnv* env, jobject thiz, ...)`
- Dart: `Future<Map<String, dynamic>> segment(String imagePath)`

### 3. Contracts
- **Serialization**: For complex results (e.g., path + metadata), use a delimited string suffix (`::label:prob`) instead of complex JNI object arrays to minimize JNI overhead and NDK dependency.
- **Path Protocol**: Return absolute local file paths for assets generated in cache.

### 4. Validation & Error Matrix
| Condition | Behavior |
|-----------|----------|
| Native failure | Throw `PlatformException` or return null map |
| Malformed suffix | Dart parser MUST use `tryParse` and handle missing parts gracefully |

### 5. Good/Base/Bad Cases
- **Good**: `"/path/to/image.png::46:0.95"` (Clean delimited string)
- **Bad**: Returning a raw `List<Object>` via JNI (Heavy boilerplate, prone to reference leaks)

### 6. Tests Required
- **Integration**: Verify Dart parser correctly extracts `topClassId` and `topConfidence` from the delimited string.
- **Unit**: Mock the `MethodChannel` to return malformed strings and verify error handling.

### 7. Wrong vs Correct

#### Wrong
Directly returning a path string and ignoring metadata, or creating complex JNI objects.
```cpp
return env->NewStringUTF(out_path.c_str()); 
```

#### Correct
Appending metadata as a delimited suffix for lightweight parsing.
```cpp
char tail[64];
std::snprintf(tail, sizeof(tail), "::%d:%.3f", top.label, top.prob);
const std::string result_path = std::string(out_path) + tail;
return env->NewStringUTF(result_path.c_str());
```

---

## Design Decision: Lightweight Delimited Suffix

**Context**: Passing structured data (Path + ClassID + Confidence) from C++ to Dart.

**Decision**: We use a `::` delimiter to append metadata to the path string. This avoids the need for complex JNI object creation or multiple channel calls.

---

## Common Mistakes: Variadic Logging

**Symptom**: NDK build failure or crash during logging.

**Cause**: Passing `std::string` directly to variadic functions like `__android_log_print`.

**Fix**: Always use `.c_str()` when passing strings to `LOGI` or similar macros.
