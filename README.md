# eks-sandbox
## 構築
1. tfstateを管理するS3bucketを指定する
```
$ cp terraform.sample.tfbackend ./terraform.tfbackend
```
terraform.tfbackendの各項目を記載する。

2. Init
```
$ terraform init --backend-config=terraform.tfbackend
```

3. apply
```
$ terraform plan
// 確認
$ terraform apply
```