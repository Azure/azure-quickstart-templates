pkg_name=national-parks
pkg_description="A sample JavaEE Web app deployed in the Tomcat8 package"
pkg_origin=oss
pkg_version=0.1.1
pkg_maintainer="oss <nopreply@sysgain.com>"
pkg_license=('Apache-2.0')
pkg_source=https://github.com/sysgain/national-parks
pkg_deps=(core/tomcat8 core/jdk8/8u131/20171011000208 core/mongo-tools)
pkg_build_deps=(core/git core/maven)
pkg_expose=(8080)
pkg_svc_user="root"
pkg_binds=(
  [database]="port"
)

# Override do_download() to pull our source code from GitHub instead
# of downloading a tarball from a URL.
do_download()
{
    build_line "do_download() =================================================="
    cd ${HAB_CACHE_SRC_PATH}

    if [ -d "${pkg_dirname}" ];
    then
        rm -rf ${pkg_dirname}
    fi

    mkdir ${pkg_dirname}
    cd ${pkg_dirname}
    GIT_SSL_NO_VERIFY=true git clone --branch master https://github.com/sysgain/national-parks.git
    return 0
}

do_clean()
{
    build_line "do_clean() ===================================================="
    return 0
}

do_unpack()
{
    # Nothing to unpack as we are pulling our code straight from github
    return 0
}

do_build()
{
    build_line "do_build() ===================================================="

    # Maven requires JAVA_HOME to be set, and can be set via:
    export JAVA_HOME=$(hab pkg path core/jdk8)

    cd ${HAB_CACHE_SRC_PATH}/${pkg_dirname}/${pkg_filename}
    mvn package
}

do_install()
{
    build_line "do_install() =================================================="

    # Our source files were copied over to the HAB_CACHE_SRC_PATH in do_build(),
    # so now they need to be copied into the root directory of our package through
    # the pkg_prefix variable. This is so that we have the source files available
    # in the package.

    local source_dir="${HAB_CACHE_SRC_PATH}/${pkg_dirname}/${pkg_filename}"
    local webapps_dir="$(hab pkg path core/tomcat8)/tc/webapps"
    cp ${source_dir}/target/${pkg_filename}.war ${webapps_dir}/
    cp ${source_dir}/target/${pkg_filename}.war ${PREFIX}/
    # Copy our seed data so that it can be loaded into Mongo using our init hook
    cp -v ${source_dir}/national-parks.json ${PREFIX}/
}

# We verify our own source code because we cloned from GitHub instead of
# providing a SHA-SUM of a tarball
do_verify()
{
    build_line "do_verify() ==================================================="
    return 0
}
