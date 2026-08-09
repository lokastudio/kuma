---
name: kuma-formkit-theme
description: KumaTheme tokens, KumaFormKit components, and macOS visual standards for KumaV4.
---

# FormKit & Theme Guidelines

## 1. Tokens First Design
- Spacing: Derive exclusively from `KumaSpacing` (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`). Zero magic numbers.
- Radii: Derive exclusively from `KumaRadius` (`sm`, `md`, `lg`, `xl`). Always use `.continuous` style.
- Typography: Derive exclusively from `KumaFont`.

## 2. FormKit Uniformity
- All form screens MUST use `KumaFormSection` and `FormKit` fields.
- Validation errors MUST be rendered inline below the target field in `.red` with `KumaFont.caption`.
