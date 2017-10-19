# Signs the resource agent RPM with the Zenoss signature.

export HOST_RPM_LOC=$(pwd)
echo "RPM Folder is ${HOST_RPM_LOC}"

echo "Cloning the mkyum repo.."
git clone git@github.com:zenoss/mkyum.git --branch master --single-branch $HOST_RPM_LOC/mkyum

echo "Building the mkyum image.."
cd mkyum
make mkyum-build

echo "Signing the resource agent rpm.."
cd mkrepo
make sign-rpms

