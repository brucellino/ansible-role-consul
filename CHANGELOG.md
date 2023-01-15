# [2.0.0](https://github.com/brucellino/ansible-role-consul/compare/v1.4.4...v2.0.0) (2023-01-15)


### Bug Fixes

* **vault:** add vault address to config ([6983ddc](https://github.com/brucellino/ansible-role-consul/commit/6983ddca4d5d49a74d616ecfedaec0e0f7c0d2a3))


* refactor(templates)!: rename consul server template (#60) ([6861680](https://github.com/brucellino/ansible-role-consul/commit/68616807fa1ff380e3836ccafef68a04865df1d2)), closes [#60](https://github.com/brucellino/ansible-role-consul/issues/60) [#59](https://github.com/brucellino/ansible-role-consul/issues/59) [#58](https://github.com/brucellino/ansible-role-consul/issues/58)


### BREAKING CHANGES

* consul configuration is not templated directly, but is now the responsibility of vault-agent.

Signed-off-by: Bruce Becker <brucellino@protonmail.com>

## [1.4.4](https://github.com/brucellino/ansible-role-consul/compare/v1.4.3...v1.4.4) (2022-12-31)


### Bug Fixes

* **vault:** fix auth mount and other parameters ([2d8ed75](https://github.com/brucellino/ansible-role-consul/commit/2d8ed750955ff0db28ef1ae6aa61fd10133aab16))

## [1.4.3](https://github.com/brucellino/ansible-role-consul/compare/v1.4.2...v1.4.3) (2022-12-29)


### Bug Fixes

* **templates:** template watches instead of copying them ([6b84ed0](https://github.com/brucellino/ansible-role-consul/commit/6b84ed081aecb2f43716ce6ffeeded36895c4870))

## [1.4.2](https://github.com/brucellino/ansible-role-consul/compare/v1.4.1...v1.4.2) (2022-12-28)


### Bug Fixes

* **resolv:** add tailscale network to dns search ([5007842](https://github.com/brucellino/ansible-role-consul/commit/5007842547df5512a8dd7c310245eb848a6f114e))
* **templates:** fix templating tags ([d5a1246](https://github.com/brucellino/ansible-role-consul/commit/d5a1246b9123a39b7b740a5c8338b5babd6acdd3))

## [1.4.1](https://github.com/brucellino/ansible-role-consul/compare/v1.4.0...v1.4.1) (2022-12-28)


### Bug Fixes

* **meta:** add role name and namespace to meta ([#54](https://github.com/brucellino/ansible-role-consul/issues/54)) ([b4ea077](https://github.com/brucellino/ansible-role-consul/commit/b4ea0779542af18a2cbc649e58185b521c4eaffa))
* **vault:** fix vault config file ([#35](https://github.com/brucellino/ansible-role-consul/issues/35)) ([77be56b](https://github.com/brucellino/ansible-role-consul/commit/77be56b2c4b85acf3e2c30d27836e53acdf8a899))

# 1.0.0 (2022-06-21)


### Features

* initial release ([ddeab26](https://github.com/brucellino/ansible-role-template/commit/ddeab264f8b4c34ed7a17bf84176e47bbb9acb7c))
