# リポジトリガイドライン / Repository Guidelines / 仓库指南

## 日本語

### プロジェクト概要（Overview）

このリポジトリは、OCI 上に ARM インスタンスを FW 用途に置いた分離ネットワーク構成を Terraform で作成する学習/運用リポジトリです。VCN、Public/Internal subnet、IGW、route table、security list、ARM/AMD インスタンスを扱います。

### コーディング規約（Coding Style Guidelines）

- `main.tf` は OCI provider、`variables.tf` は入力変数、`instance.tf` はネットワークとインスタンス定義として責務を維持する。
- CIDR、固定 Private IP、shape、image OCID を変更する場合は README と plan の整合を確認する。
- コメントは実装と矛盾させない。古い CIDR コメントが残っていないか確認する。

### セキュリティ（Security considerations）

- `terraform.tfvars`、Terraform state、OCI API 秘密鍵、fingerprint、OCID の扱いに注意し、秘密情報はコミットしない。
- Public subnet の SSH 許可は最小化を検討し、`0.0.0.0/0` を広げる変更は明示的に理由を書く。
- ARM FW と internal AMD の経路/ProxyJump 前提を崩す変更は影響範囲を確認する。

### ビルド＆テスト手順（Build & Test）

- 基本確認: `terraform fmt -check`, `terraform validate`, `terraform plan -no-color`。
- 適用前に OCI region、availability domain、compartment、固定 IP 重複を確認する。
- 適用後は ARM FW SSH、internal AMD への接続、ProxyJump 経路を確認する。

### 知識＆ライブラリ（Knowledge & Library）

- OCI provider、OCI networking、Compute shape/image 仕様を変更する前は、利用可能なら Context7 MCP Server で `resolve-library-id` → `get-library-docs` を使う。
- Context7 が使えない場合は Terraform Registry と Oracle Cloud 公式ドキュメントを優先する。

### メンテナンス_ポリシー（Maintenance policy）

- 期待リモートは `https://github.com/zhuchuanhui/learn-terraform-oci.git`。push 前に `git remote -v` を確認する。
- README 更新時は実際の Terraform resource と plan を基準にする。
- 作業前に `git status -sb`, `git remote -v`, `git branch -vv` を確認し、push 前は `git push --dry-run` を行う。

## English

### Overview

This repository uses Terraform to build an OCI separated network with an ARM instance acting as a firewall. It manages VCN, public/internal subnets, IGW, route table, security list, and ARM/AMD instances.

### Coding Style Guidelines

- Keep `main.tf` for the OCI provider, `variables.tf` for inputs, and `instance.tf` for networking and instances.
- When changing CIDRs, fixed private IPs, shapes, or image OCIDs, verify README and plan alignment.
- Keep comments consistent with implementation; remove stale CIDR notes.

### Security considerations

- Do not commit `terraform.tfvars`, state files, OCI API private keys, fingerprints, or sensitive OCIDs.
- Minimize SSH exposure on public subnets and document any broad `0.0.0.0/0` change.
- Check impact before changing ARM FW, internal AMD, or ProxyJump assumptions.

### Build & Test

- Run `terraform fmt -check`, `terraform validate`, and `terraform plan -no-color`.
- Before apply, confirm OCI region, availability domain, compartment, and fixed-IP conflicts.
- After apply, verify ARM FW SSH, internal AMD connectivity, and ProxyJump paths.

### Knowledge & Library

- Before changing OCI provider, networking, Compute shape, or image behavior, use Context7 MCP Server when available: `resolve-library-id` then `get-library-docs`.
- If Context7 is unavailable, prefer Terraform Registry and Oracle Cloud official docs.

### Maintenance policy

- Expected remote: `https://github.com/zhuchuanhui/learn-terraform-oci.git`; check `git remote -v` before pushing.
- README updates must follow actual Terraform resources and plan.
- Check `git status -sb`, `git remote -v`, and `git branch -vv` before work; use `git push --dry-run` before pushing.

## 中文

### 项目概要

此仓库使用 Terraform 在 OCI 上创建以 ARM 实例作为防火墙的隔离网络，管理 VCN、Public/Internal subnet、IGW、route table、security list 和 ARM/AMD 实例。

### 编码规范

- `main.tf` 负责 OCI provider，`variables.tf` 负责输入变量，`instance.tf` 负责网络和实例。
- 修改 CIDR、固定 Private IP、shape、image OCID 时，同步确认 README 和 plan。
- 注释必须与实现一致，清理过期 CIDR 注释。

### 安全注意事项

- 不要提交 `terraform.tfvars`、state、OCI API 私钥、fingerprint 或敏感 OCID。
- Public subnet SSH 暴露应最小化，扩大 `0.0.0.0/0` 时必须说明理由。
- 修改 ARM FW、internal AMD 或 ProxyJump 前提前，确认影响范围。

### 构建与测试

- 执行 `terraform fmt -check`、`terraform validate`、`terraform plan -no-color`。
- apply 前确认 OCI region、availability domain、compartment 和固定 IP 冲突。
- apply 后确认 ARM FW SSH、internal AMD 连接和 ProxyJump 路径。

### 知识与库

- 修改 OCI provider、网络、Compute shape 或 image 行为前，如可用，使用 Context7 MCP Server: `resolve-library-id` → `get-library-docs`。
- 如果 Context7 不可用，优先参考 Terraform Registry 和 Oracle Cloud 官方文档。

### 维护策略

- 预期远程地址: `https://github.com/zhuchuanhui/learn-terraform-oci.git`；push 前检查 `git remote -v`。
- README 更新必须基于真实 Terraform resource 和 plan。
- 工作前检查 `git status -sb`、`git remote -v`、`git branch -vv`；push 前执行 `git push --dry-run`。
