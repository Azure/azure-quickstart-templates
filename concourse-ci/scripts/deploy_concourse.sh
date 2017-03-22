set -e

bosh upload stemcell REPLACE_WITH_STEMCELL_URL --skip-if-exists

bosh upload release REPLACE_WITH_CONCOURSE_RELEASE_URL --skip-if-exists
bosh upload release REPLACE_WITH_GARDEN_RELEASE_URL --skip-if-exists

bosh update cloud-config cloud.yml
bosh deployment concourse.yml

bosh -n deploy