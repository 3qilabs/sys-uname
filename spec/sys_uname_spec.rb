##############################################################################
# sys_uname_spec.rb
#
# Test suite for the sys-uname library. Run 'rake test' to execute tests.
##############################################################################
require 'rspec'
require 'sys/uname'
require 'rbconfig'

RSpec.describe Sys::Uname do
  context "universal singleton methods" do
    example "version constant is set to expected value" do
      expect(Sys::Uname::VERSION).to eql('1.1.1')
      expect(Sys::Uname::VERSION.frozen?).to be(true)
    end

    example "machine singleton method works as expected" do
      expect(described_class).to respond_to(:machine)
      expect{ described_class.machine }.not_to raise_error
      expect(described_class.machine).to be_kind_of(String)
      expect(described_class.machine.size).to be > 0
    end

    example "version singleton method works as expected" do
      expect(described_class).to respond_to(:version)
      expect{ described_class.version }.not_to raise_error
      expect(described_class.version).to be_kind_of(String)
      expect(described_class.version.size).to be > 0
    end

    example "nodename singleton method works as expected" do
      expect(described_class).to respond_to(:nodename)
      expect{ described_class.nodename }.not_to raise_error
      expect(described_class.nodename).to be_kind_of(String)
      expect(described_class.nodename.size).to be > 0
    end

    example "release singleton method works as expected" do
      expect(described_class).to respond_to(:release)
      expect{ described_class.release }.not_to raise_error
      expect(described_class.release).to be_kind_of(String)
      expect(described_class.release.size).to be > 0
    end

    example "sysname singleton method works as expected" do
      expect(described_class).to respond_to(:sysname)
      expect{ described_class.sysname }.not_to raise_error
      expect(described_class.sysname).to be_kind_of(String)
      expect(described_class.sysname.size).to be > 0
    end
  end

  context "singleton methods for Solaris only", :if => RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i do
    example "architecture singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:architecture)
      expect{ described_class.architecture }.not_to raise_error
      expect(described_class.architecture).to be_kind_of(String)
    end

    example "platform singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:platform)
      expect{ described_class.platform }.not_to raise_error
      expect(described_class.platform).to be_kind_of(String)
    end

    example "isa_list singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:isa_list)
      expect{ described_class.isa_list }.not_to raise_error
      expect(described_class.isa_list).to be_kind_of(String)
    end

    example "hw_provider singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:hw_provider)
      expect{ described_class.hw_provider }.not_to raise_error
      expect(described_class.hw_provider).to be_kind_of(String)
    end

    example "hw_serial singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:hw_serial)
      expect{ described_class.hw_serial }.not_to raise_error
      expect(described_class.hw_serial).to be_kind_of(Integer)
    end

    example "srpc_domain singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:srpc_domain)
      expect{ described_class.srpc_domain }.not_to raise_error
      expect(described_class.srpc_domain).to be_kind_of(String)
    end

    example "dhcp_cache singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:dhcp_cache)
      expect{ described_class.dhcp_cache }.not_to raise_error
      expect(described_class.dhcp_cache).to be_kind_of(String)
    end
  end

  context "singleton methods for BSD and Darwin only", :if => RbConfig::CONFIG['host_os'] =~ /darwin|bsd/i do
    example "model singleton method works as expected on BSD and Darwin" do
      expect(described_class).to respond_to(:model)
      expect{ described_class.model }.not_to raise_error
      expect(described_class.model).to be_kind_of(String)
    end
  end

  context "singleton methods for HP-UX only", :if => RbConfig::CONFIG['host_os'] =~ /hpux/i do
    example "id_number singleton method works as expected on HP-UX" do
      expect(described_class).to respond_to(:id_number)
      expect{ described_class.id_number }.not_to raise_error
      expect(described_class.id_number).to be_kind_of(String)
    end
  end

  context "uname struct" do
    example "uname struct contains expected members based on platform" do
      members = %w/sysname nodename machine version release/
      case RbConfig::CONFIG['host_os']
        when /linux/i
          members.push('domainname')
        when /sunos|solaris/i
          members.push(
            'architecture', 'platform', 'hw_serial', 'hw_provider',
            'srpc_domain', 'isa_list', 'dhcp_cache'
          )
        when /powerpc|darwin|bsd/i
          members.push('model')
        when /hpux/i
          members.push('id')
        when /win32|mingw|cygwin|dos|windows/i
          members = %w[
            boot_device build_number build_type caption code_set country_code
            creation_class_name cscreation_class_name csd_version cs_name
            current_time_zone debug description distributed encryption_level
            foreground_application_boost free_physical_memory
            free_space_in_paging_files free_virtual_memory
            install_date large_system_cache last_bootup_time local_date_time locale
            manufacturer max_number_of_processes max_process_memory_size
            name number_of_licensed_users number_of_processes
            number_of_users organization os_language os_product_suite
            os_type other_type_description plus_product_id
            plus_version_number primary quantum_length quantum_type
            registered_user serial_number service_pack_major_version
            service_pack_minor_version size_stored_in_paging_files
            status system_device system_directory total_swap_space_size
            total_virtual_memory_size total_visible_memory_size version
            windows_directory
          ]
      end

      members.map!{ |e| e.to_sym } if RUBY_VERSION.to_f >= 1.9

      expect{ described_class.uname }.not_to raise_error
      expect(described_class.uname).to be_kind_of(Struct)
      expect(described_class.uname.members.sort).to eql(members.sort)
    end
  end

  context "ffi" do
    example "ffi and internal functions are not public" do
      methods = described_class.methods(false).map{ |e| e.to_s }
      expect(methods).not_to include('get_model')
      expect(methods).not_to include('get_si')
      expect(methods).not_to include('uname_c')
      expect(methods).not_to include('sysctl')
      expect(methods).not_to include('sysinfo')
    end
  end

  context "instance methods for MS Windows", :if => File::ALT_SEPARATOR do
    example "boot_device" do
      expect{ described_class.uname.boot_device }.not_to raise_error
      expect(described_class.uname.boot_device).to be_kind_of(String)
    end

    example "build_number" do
      expect{ described_class.uname.build_number }.not_to raise_error
      expect(described_class.uname.build_number).to be_kind_of(String)
    end

    example "build_type" do
      expect{ described_class.uname.build_type }.not_to raise_error
      expect(described_class.uname.build_type).to be_kind_of(String)
    end

    example "caption" do
      expect{ described_class.uname.caption }.not_to raise_error
      expect(described_class.uname.caption).to be_kind_of(String)
    end

    example "code_set" do
      expect{ described_class.uname.code_set }.not_to raise_error
      expect(described_class.uname.code_set).to be_kind_of(String)
    end

    example "country_code" do
      expect{ described_class.uname.country_code }.not_to raise_error
      expect(described_class.uname.country_code).to be_kind_of(String)
    end

    example "creation_class_name" do
      expect{ described_class.uname.creation_class_name }.not_to raise_error
      expect(described_class.uname.creation_class_name).to be_kind_of(String)
    end

    example "cscreation_class_name" do
      expect{ described_class.uname.cscreation_class_name }.not_to raise_error
      expect(described_class.uname.cscreation_class_name).to be_kind_of(String)
    end

    example "csd_version" do
      expect{ described_class.uname.csd_version }.not_to raise_error
      expect(described_class.uname.csd_version).to be_kind_of(String).or be_kind_of(NilClass)
    end

    example "cs_name" do
      expect{ described_class.uname.cs_name }.not_to raise_error
      expect(described_class.uname.cs_name).to be_kind_of(String)
    end

    example "current_time_zone" do
      expect{ described_class.uname.current_time_zone }.not_to raise_error
      expect(described_class.uname.current_time_zone).to be_kind_of(Fixnum)
    end

    example "debug" do
      expect{ described_class.uname.debug }.not_to raise_error
      expect(described_class.uname.debug).to be(true).or be(false)
    end

    example "description" do
      expect{ described_class.uname.description }.not_to raise_error
      expect(described_class.uname.description).to be_kind_of(String)
    end

    example "distributed" do
      expect{ described_class.uname.distributed }.not_to raise_error
      expect(described_class.uname.distributed).to be(true).or be(false)
    end

    example "encryption_level" do
      expect{ described_class.uname.encryption_level }.not_to raise_error
      expect(described_class.uname.encryption_level).to be_kind_of(Integer)
    end

    example "foreground_application_boost" do
      expect{ described_class.uname.foreground_application_boost }.not_to raise_error
      expect(described_class.uname.foreground_application_boost).to be_kind_of(Integer)
    end

    example "free_physical_memory" do
      expect{ described_class.uname.free_physical_memory }.not_to raise_error
      expect(described_class.uname.free_physical_memory).to be_kind_of(Integer)
    end

    example "free_space_in_paging_files" do
      expect{ described_class.uname.free_space_in_paging_files }.not_to raise_error
      expect(described_class.uname.free_space_in_paging_files).to be_kind_of(Integer)
    end

    example "free_virtual_memory" do
      expect{ described_class.uname.free_virtual_memory}.not_to raise_error
      expect(described_class.uname.free_virtual_memory).to be_kind_of(Integer)
    end

    example "install_date" do
      expect{ described_class.uname.install_date}.not_to raise_error
      expect(described_class.uname.install_date).to be_kind_of(Time)
    end

    example "large_system_cache" do
      expect{ described_class.uname.large_system_cache}.not_to raise_error
      expect(described_class.uname.large_system_cache).to be_kind_of(Time).or be_kind_of(NilClass)
    end

=begin
    example "last_bootup_time" do
      expect{ described_class.uname.last_bootup_time}
      expect(Time, described_class.uname.last_bootup_time)
    end

    example "local_date_time" do
      expect{ described_class.uname.local_date_time}
      expect(Time, described_class.uname.local_date_time)
    end

    example "locale" do
      expect{ described_class.uname.locale}
      expect(String, described_class.uname.locale)
    end

    example "manufacturer" do
      expect{ described_class.uname.manufacturer}
      expect(String, described_class.uname.manufacturer)
    end

    example "max_number_of_processes" do
      expect{ described_class.uname.max_number_of_processes}
      expect(Fixnum, described_class.uname.max_number_of_processes)
    end

    example "max_process_memory_size" do
      expect{ described_class.uname.max_process_memory_size}
      expect(Integer, described_class.uname.max_process_memory_size)
    end

    example "name" do
      expect{ described_class.uname.name}
      expect(String, described_class.uname.name)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #example "number_of_licensed_users
    #   expect{ described_class.uname.number_of_licensed_users}
    #   expect(Fixnum,described_class.uname.number_of_licensed_users)
    #end

    example "number_of_processes" do
      expect{ described_class.uname.number_of_processes}
      expect(Fixnum, described_class.uname.number_of_processes)
    end

    example "number_of_users" do
      expect{ described_class.uname.number_of_users}
      expect(Fixnum, described_class.uname.number_of_users)
    end

    example "organization" do
      expect{ described_class.uname.organization}
      expect(String, described_class.uname.organization)
    end

    # Eventually replace Fixnum with a string (?)
    example "os_language" do
      expect{ described_class.uname.os_language}
      expect(Fixnum, described_class.uname.os_language)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #example "os_product_suite
    #   expect{ described_class.uname.os_product_suite}
    #   expect(Fixnum,described_class.uname.os_product_suite)
    #end

    example "os_type" do
       expect{ described_class.uname.os_type}
       expect(Fixnum, described_class.uname.os_type)
    end

    # Fails?
    #example "other_type_restriction
    #   expect{ described_class.uname.other_type_restriction}
    #   expect(Fixnum,described_class.uname.other_type_restriction)
    #end

    # Might be nil
    example "plus_product_id" do
      expect{ described_class.uname.plus_product_id }
    end

    # Might be nil
    example "plus_version_number" do
      expect{ described_class.uname.plus_version_number}
    end

    example "primary" do
      expect{ described_class.uname.primary}
      assert_boolean(described_class.uname.primary)
    end

    # Not yet supported - WinXP or later only
    # example "product_type
    #   expect{ described_class.uname.product_type}
    #   expect(Fixnum,described_class.uname.product_type)
    # end

    example "quantum_length" do
      expect{ described_class.uname.quantum_length}
      expect([Fixnum, NilClass], described_class.uname.quantum_length)
    end

    example "quantum_type" do
      expect{ described_class.uname.quantum_type}
      expect([Fixnum, NilClass], described_class.uname.quantum_type)
    end

    example "registered_user" do
      expect{ described_class.uname.registered_user}
      expect(String, described_class.uname.registered_user)
    end

    example "serial_number" do
      expect{ described_class.uname.serial_number}
      expect(String, described_class.uname.serial_number)
    end

    # This is nil on NT 4
    example "service_pack_major_version" do
      expect{ described_class.uname.service_pack_major_version}
      expect(Fixnum, described_class.uname.service_pack_major_version)
    end

    # This is nil on NT 4
    example "service_pack_minor_version" do
      expect{ described_class.uname.service_pack_minor_version}
      expect(Fixnum, described_class.uname.service_pack_minor_version)
    end

    example "status" do
      expect{ described_class.uname.status}
      expect(String, described_class.uname.status)
    end

    # Not yet supported - WinXP or later only
    #example "suite_mask
    #   expect{ described_class.uname.suite_mask}
    #   expect(String,described_class.uname.suite_mask)
    #end

    example "system_device" do
      expect{ described_class.uname.system_device}
      expect(String, described_class.uname.system_device)
    end

    example "system_directory" do
      expect{ described_class.uname.system_directory}
      expect(String, described_class.uname.system_directory)
    end

    # Not yet supported - WinXP or later only
    #example "system_drive
    #   expect{ described_class.uname.system_drive}
    #   expect(String,described_class.uname.system_drive)
    #end

    # Fails on Win XP Pro - returns nil - reason unknown
    #example "total_swap_space_size
    #   expect{ described_class.uname.total_swap_space_size}
    #   expect(Fixnum,described_class.uname.total_swap_space_size)
    #end

    example "total_virtual_memory_size" do
      expect{ described_class.uname.total_virtual_memory_size}
      expect(Fixnum, described_class.uname.total_virtual_memory_size)
    end

    example "total_visible_memory_size" do
      expect{ described_class.uname.total_visible_memory_size}
      expect(Fixnum, described_class.uname.total_visible_memory_size)
    end

    example "version" do
      expect{ described_class.uname.version}
      expect(String, described_class.uname.version)
    end

    example "windows_directory" do
      expect{ described_class.uname.windows_directory}
      expect(String, described_class.uname.windows_directory)
    end
=end
  end
end