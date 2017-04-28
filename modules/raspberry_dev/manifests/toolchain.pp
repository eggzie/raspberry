class raspberry_dev::toolchain {
  $toolchain_url = 'https://github.com/raspberrypi/tools'

  exec {'download-toolchain':
    command => "git clone ${toolchain_url}",
    cwd => $raspberry_dev::config::debs_dir,
    creates => "${raspberry_dev::config::debs_dir}/tools"
  } -> exec {'install-toolchain':
    command => "cp -r arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/* \
                ${raspberry_dev::config::tools_prefix}",
    cwd => "${raspberry_dev::config::debs_dir}/tools"
  }
}
