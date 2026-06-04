# Native Layer Specs

Guidelines for Android/iOS native code and high-performance C++ integrations.

---

## Specs

| Spec | Description |
|------|-------------|
| [NCNN Guidelines](./ncnn-guidelines.md) | High-performance neural network inference and post-processing |
| [JNI/FFI Bridge](./bridge-guidelines.md) | Data passing between Dart and Native (C++/Kotlin/Swift) |

---

## Quality Check

- [ ] Memory safety: No manual `new`/`delete` leaks in C++?
- [ ] JNI references: Local references released?
- [ ] Threading: Heavy tasks (inference) offloaded from Main/UI thread?
- [ ] Error handling: Exceptions propagated back to Dart?
