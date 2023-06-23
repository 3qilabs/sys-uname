# frozen_string_literal: true

require 'socket'
require 'time'
#require 'win32ole'

# The Sys module provides a namespace only.
module Sys
  # The Uname class encapsulates uname (platform) information.
  class Uname
    # This is the error raised if any of the Sys::Uname methods should fail.
    class Error < StandardError; end

    fields = %w[
      boot_device
      build_number
      build_type
      caption
      code_set
      country_code
      creation_class_name
      cscreation_class_name
      csd_version
      cs_name
      current_time_zone
      debug
      description
      distributed
      encryption_level
      foreground_application_boost
      free_physical_memory
      free_space_in_paging_files
      free_virtual_memory
      install_date
      last_bootup_time
      local_date_time
      locale
      manufacturer
      max_number_of_processes
      max_process_memory_size
      name
      number_of_licensed_users
      number_of_processes
      number_of_users
      organization
      os_language
      os_product_suite
      os_type
      other_type_description
      plus_product_id
      plus_version_number
      primary
      product_type
      quantum_length
      quantum_type
      registered_user
      serial_number
      service_pack_major_version
      service_pack_minor_version
      size_stored_in_paging_files
      status
      suite_mask
      system_device
      system_directory
      system_drive
      total_swap_space_size
      total_virtual_memory_size
      total_visible_memory_size
      version
      windows_directory
    ]

    # The UnameStruct is used to store platform information for some methods.
    UnameStruct = Struct.new('UnameStruct', *fields)

    # Returns the version plus patch information of the operating system,
    # separated by a hyphen, e.g. "2915-Service Pack 2".
    #--
    # The instance name is unpredictable, so we have to resort to using
    # the 'InstancesOf' method to get the data we need, rather than
    # including it as part of the connection.
    #
    def self.version(host = Socket.gethostname)
      begin
        host_os = RbConfig::CONFIG['host_os']
      rescue Exception => err
        raise Error, err
      else
        case host_os
        when /darwin|mac os/
          # macOS version
          `sw_vers -productVersion`.strip
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          # Windows version
          `ver`.strip
        when /linux/
          # Linux version
          `lsb_release -r -s`.strip
        when /solaris|bsd/
          # Solaris or BSD version
          `uname -r`.strip
        else
          'Unknown'
        end
      end
    end

    # Returns the operating system name, e.g. "Microsoft Windows XP Home"
    #
    def self.sysname(host = Socket.gethostname)
      begin
        host_os = RbConfig::CONFIG['host_os']
      rescue Exception => err
        raise Error, err
      else
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          'Windows'
        when /darwin|mac os/
          'Mac OS'
        when /linux/
          'Linux'
        when /solaris|bsd/
          'Unix'
        else
          'Unknown'
        end
      end
    end

    # Returns the nodename.  This is usually, but not necessarily, the
    # same as the system's hostname.
    #
    def self.nodename(host = Socket.gethostname)
      begin
        host_os = RbConfig::CONFIG['host_os']
      rescue Exception => err
        raise Error, err
      else
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          'Windows'
        when /darwin|mac os/
          'Mac OS'
        when /linux/
          'Linux'
        when /solaris|bsd/
          'Unix'
        else
          'Unknown'
        end
      end
    end

    # Returns the CPU architecture, e.g. "x86"
    #
    def self.architecture(cpu_num = 0, host = Socket.gethostname)

      begin
        cpu_architecture = RbConfig::CONFIG['target_cpu']
      rescue Exception => err
        raise Error, err
      else
        cpu_architecture
      end
    end

    # Returns the machine hardware type.  e.g. "i686".
    #--
    # This may or may not return the expected value because some CPU types
    # were unknown to the OS when the OS was originally released.  It
    # appears that MS doesn't necessarily patch this, either.
    #
    def self.machine(cpu_num = 0, host = Socket.gethostname)

      begin
        cpu_architecture = RbConfig::CONFIG['target_cpu']
      rescue Exception => err
        raise Error, err
      else
        # Convert a family number into the equivalent string
        cpu_architecture
      end
    end

    # Returns the release number, e.g. 5.1.2600.
    #
    def self.release(host = Socket.gethostname)

      begin
        host_os = RbConfig::CONFIG['host_os']
      rescue Exception => err
        raise Error, err
      else
        case host_os
        when /darwin|mac os/
          # macOS version
          `sw_vers -productVersion`.strip
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          # Windows version
          `ver`.strip
        when /linux/
          # Linux version
          `lsb_release -r -s`.strip
        when /solaris|bsd/
          # Solaris or BSD version
          `uname -r`.strip
        else
          'Unknown'
        end
      end
    end

    # Returns a struct of type UnameStruct that contains sysname, nodename,
    # machine, version, and release, as well as a plethora of other fields.
    # Please see the MSDN documentation for what each of these fields mean.
    #
    def self.uname(host = Socket.gethostname)
      begin
        host_os = RbConfig::CONFIG['host_os']
        cpu_architecture = RbConfig::CONFIG['target_cpu']

      rescue Exception => err
        raise Error, err
      else
        UnameStruct.new(
            host_os,
            cpu_architecture,
            `ver`.strip
        )
      end
    end

    # Converts a string in the format '20040703074625.015625-360' into a
    # Ruby Time object.
    #
    def self.parse_ms_date(str)
      return if str.nil?
      Time.parse(str.split('.')[0])
    end

    private_class_method :parse_ms_date

    # There is a bug in win32ole where uint64 types are returned as a
    # String rather than a Fixnum/Bignum.  This deals with that for now.
    #
    def self.convert(str)
      return nil if str.nil?  # Don't turn nil into 0
      str.to_i
    end

    private_class_method :convert
  end
end
