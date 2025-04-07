#!/bin/bash

echo "🌍 Fetching all AWS regions..."
regions=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)

for region in $regions; do
  echo -e "\n🗺️ Region: $region"

  # EC2
  echo "🔹 Terminating EC2 instances..."
  ec2_ids=$(aws ec2 describe-instances --region $region --query "Reservations[*].Instances[*].InstanceId" --output text)
  for id in $ec2_ids; do
    aws ec2 terminate-instances --region $region --instance-ids $id
  done

  # EBS Volumes
  echo "🔹 Deleting unattached EBS volumes..."
  volumes=$(aws ec2 describe-volumes --region $region --filters Name=status,Values=available --query "Volumes[*].VolumeId" --output text)
  for vol in $volumes; do
    aws ec2 delete-volume --region $region --volume-id $vol
  done

  # Elastic IPs
  echo "🔹 Releasing unused Elastic IPs..."
  eips=$(aws ec2 describe-addresses --region $region --query "Addresses[?AssociationId==null].AllocationId" --output text)
  for eip in $eips; do
    aws ec2 release-address --region $region --allocation-id $eip
  done

  # RDS
  echo "🔹 Deleting RDS instances..."
  rds_ids=$(aws rds describe-db-instances --region $region --query "DBInstances[*].DBInstanceIdentifier" --output text)
  for rds in $rds_ids; do
    aws rds delete-db-instance --region $region --db-instance-identifier $rds --skip-final-snapshot
  done

  # Lambda
  echo "🔹 Deleting Lambda functions..."
  lambdas=$(aws lambda list-functions --region $region --query "Functions[*].FunctionName" --output text)
  for fn in $lambdas; do
    aws lambda delete-function --region $region --function-name $fn
  done

  # Snapshots
  echo "🔹 Deleting EBS snapshots..."
  snapshots=$(aws ec2 describe-snapshots --region $region --owner-ids self --query "Snapshots[*].SnapshotId" --output text)
  for snap in $snapshots; do
    aws ec2 delete-snapshot --region $region --snapshot-id $snap
  done
done

# S3 Buckets (global)
echo -e "\n🌐 Deleting all S3 buckets..."
buckets=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)
for bucket in $buckets; do
  echo "🧹 Deleting bucket $bucket..."
  aws s3 rm s3://$bucket --recursive
  aws s3api delete-bucket --bucket $bucket
done

echo -e "\n✅ All resources cleaned up!"
