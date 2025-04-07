#!/bin/bash

echo "🌍 Fetching all AWS regions..."
regions=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

for region in $regions; do
  echo "🧹 Cleaning resources in region: $region"

  echo "🔹 Terminating EC2 Instances..."
  instance_ids=$(aws ec2 describe-instances --region $region --query "Reservations[*].Instances[*].InstanceId" --output text)
  for id in $instance_ids; do
    aws ec2 terminate-instances --region $region --instance-ids $id
  done

  echo "🔹 Deleting EBS Volumes..."
  volumes=$(aws ec2 describe-volumes --region $region --query "Volumes[?State=='available'].VolumeId" --output text)
  for vol in $volumes; do
    aws ec2 delete-volume --region $region --volume-id $vol
  done

  echo "🔹 Deleting EBS Snapshots..."
  snapshots=$(aws ec2 describe-snapshots --owner-ids self --region $region --query "Snapshots[*].SnapshotId" --output text)
  for snap in $snapshots; do
    aws ec2 delete-snapshot --region $region --snapshot-id $snap
  done

  echo "🔹 Deleting RDS Snapshots..."
  rds_snaps=$(aws rds describe-db-snapshots --region $region --query "DBSnapshots[*].DBSnapshotIdentifier" --output text)
  for snap in $rds_snaps; do
    aws rds delete-db-snapshot --region $region --db-snapshot-identifier $snap
  done

  echo "🔹 Deleting RDS Instances..."
  rds_instances=$(aws rds describe-db-instances --region $region --query "DBInstances[*].DBInstanceIdentifier" --output text)
  for rds in $rds_instances; do
    aws rds delete-db-instance --region $region --db-instance-identifier $rds --skip-final-snapshot --delete-automated-backups
  done

  echo "🔹 Deleting CloudWatch Log Groups..."
  log_groups=$(aws logs describe-log-groups --region $region --query "logGroups[*].logGroupName" --output text)
  for log in $log_groups; do
    aws logs delete-log-group --region $region --log-group-name $log
  done

  echo "🔹 Deleting Lambda Functions..."
  lambda_funcs=$(aws lambda list-functions --region $region --query "Functions[*].FunctionName" --output text)
  for func in $lambda_funcs; do
    aws lambda delete-function --region $region --function-name $func
  done

  echo "🔹 Releasing Elastic IPs..."
  alloc_ids=$(aws ec2 describe-addresses --region $region --query "Addresses[*].AllocationId" --output text)
  for alloc in $alloc_ids; do
    aws ec2 release-address --region $region --allocation-id $alloc
  done

  echo "✅ Region $region cleaned!"
done

echo "🌐 Deleting all S3 Buckets..."
buckets=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)
for bucket in $buckets; do
  echo "⚠️ Deleting bucket: $bucket"
  aws s3 rm s3://$bucket --recursive
  aws s3api delete-bucket --bucket $bucket
done

echo "💬 Final Billing Tip: Check Cost Explorer for any active Support Plan or unused services."
echo "✅ Cleanup complete. You shouldn't be charged a single rupee 💸"
