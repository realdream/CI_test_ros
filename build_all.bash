#!/usr/bin/env bash
pushd ./ > /dev/null
basepath=$(cd `dirname $0`; pwd)
logfile=log.txt
repos_file=ROS2_ardent.repos
vsc_import=0
build_ament=0
build_core=0
build_rcl=0
build_other=0
wrapall=0
wrap_dir=ros2_wrap
codesign_identity=0
symlink_install=""
# export XCODE_XCCONFIG_FILE=$basepath/ios.xcconfig
while getopts "iacrosw:" arg
do
    case $arg in
        i)
            vsc_import=1
            ;;
        a)
            build_ament=1
            ;;
        c)
            build_core=1
            ;;
        r)
            build_rcl=1
            ;;
        o)
            build_other=1
            ;;
        s)
            symlink_install="--symlink-install"
            ;;
        w)
            wrapall=1
            codesign_identity=$OPTARG
            ;;            
        ?)
            echo "invild argument."
            ;;
        esac
done

if [ $vsc_import -eq 1 ]
then
    cd $basepath
    vcs import . < $repos_file
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "clone repo failed"
        exit -1
    fi

fi

if [ $build_ament -eq 1 ]
then
    cd $basepath/ros2_ament
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "cd ros2_ament failed"
        exit -1
    fi
    $basepath/ros2_ament/src/ament/ament_tools/scripts/ament.py build
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "build ament failed"
        exit -1
    fi
fi

if [ $build_core -eq 1 ]
then
    cd $basepath/ros2_core
    source $basepath/ros2_ament/install/setup.bash
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "init ros2_core failed"
        exit -1
    fi
    ament build $symlink_install --parallel
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "build core failed"
        exit -1
    fi
fi

if [ $build_rcl -eq 1 ]
then
    cd $basepath/ros2_rcl
    source $basepath/ros2_core/install/setup.bash
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "init ros2_rclcpp failed"
        exit -1
    fi
    ament build $symlink_install --parallel
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "build rcl failed"
        exit -1
    fi
fi

if [ $build_other -eq 1 ]
then
    cd $basepath/ros2_other
    source $basepath/ros2_rcl/install/setup.bash
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "init ros2_rclcpp failed"
        exit -1
    fi
    ament build $symlink_install --parallel
    if [ $? -ne 0 ]
    then
        popd > /dev/null
        echo "build other failed"
        exit -1
    fi
fi

popd > /dev/null