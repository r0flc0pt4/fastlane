require 'shellwords'
require 'credentials_manager'

describe FastlaneCore do
  describe FastlaneCore::ItunesTransporter do
    def shell_upload_command(provider_short_name = nil)
      [
        '"' + FastlaneCore::Helper.transporter_path + '"',
        "-m upload",
        '-u "fabric.devtools@gmail.com"',
        ("-p '\\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<'" unless FastlaneCore::Helper.windows?),
        ("-p \\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<" if FastlaneCore::Helper.windows?),
        "-f \"/tmp/my.app.id.itmsp\"",
        "-t DAV",
        "-t Signiant",
        "-k 100000",
        ("-WONoPause true" if FastlaneCore::Helper.windows?),
        ("-itc_provider #{provider_short_name}" if provider_short_name)
      ].compact.join(' ')
    end

    def shell_download_command(provider_short_name = nil)
      [
        '"' + FastlaneCore::Helper.transporter_path + '"',
        '-m lookupMetadata',
        '-u "fabric.devtools@gmail.com"',
        ("-p '\\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<'" unless FastlaneCore::Helper.windows?),
        ("-p \\!\\>\\ p@\\$s_-\\+\\=w'\"\\'\"'o\\%rd\\\"\\&\\#\\*\\<" if FastlaneCore::Helper.windows?),
        "-apple_id my.app.id",
        "-destination '/tmp'",
        ("-itc_provider #{provider_short_name}" if provider_short_name)
      ].compact.join(' ')
    end

    def java_upload_command(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-classpath #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        'com.apple.transporter.Application',
        "-m upload",
        "-u fabric.devtools@gmail.com",
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        "-f /tmp/my.app.id.itmsp",
        "-t DAV",
        "-t Signiant",
        "-k 100000",
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    def java_download_command(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-classpath #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        'com.apple.transporter.Application',
        '-m lookupMetadata',
        '-u fabric.devtools@gmail.com',
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        '-apple_id my.app.id',
        '-destination /tmp',
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    def java_upload_command_9(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-jar #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        "-m upload",
        "-u fabric.devtools@gmail.com",
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        "-f /tmp/my.app.id.itmsp",
        "-t DAV",
        "-t Signiant",
        "-k 100000",
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    def java_download_command_9(provider_short_name = nil)
      [
        FastlaneCore::Helper.transporter_java_executable_path.shellescape,
        "-Djava.ext.dirs=#{FastlaneCore::Helper.transporter_java_ext_dir.shellescape}",
        '-XX:NewSize=2m',
        '-Xms32m',
        '-Xmx1024m',
        '-Xms1024m',
        '-Djava.awt.headless=true',
        '-Dsun.net.http.retryPost=false',
        "-jar #{FastlaneCore::Helper.transporter_java_jar_path.shellescape}",
        '-m lookupMetadata',
        '-u fabric.devtools@gmail.com',
        "-p \\!\\>\\ p@\\$s_-\\+\\=w\\'o\\%rd\\\"\\&\\#\\*\\<",
        '-apple_id my.app.id',
        '-destination /tmp',
        ("-itc_provider #{provider_short_name}" if provider_short_name),
        '2>&1'
      ].compact.join(' ')
    end

    describe "with Xcode 7.x installed", requires_xcode: true do
      before(:each) { allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('7.3') }

      describe "by default" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command)
          end
        end
      end

      describe "use_shell_script is false with a itc_provider short name set" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false, 'abcd1234')
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command('abcd1234'))
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false, 'abcd1234')
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command('abcd1234'))
          end
        end
      end

      describe "use_shell_script is true with a itc_provider short name set" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true, 'abcd1234')
            expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command('abcd1234'))
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true, 'abcd1234')
            expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command('abcd1234'))
          end
        end
      end

      describe "when use shell script ENV var is set" do
        describe "upload command generation" do
          it 'generates a call to the shell script' do
            with_env_values('FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT' => 'true') do
              transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
              expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
            end
          end
        end

        describe "download command generation" do
          it 'generates a call to the shell script' do
            with_env_values('FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT' => 'true') do
              transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<")
              expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
            end
          end
        end
      end

      describe "use_shell_script is true" do
        describe "upload command generation" do
          it 'generates a call to the shell script' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true)
            expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to the shell script' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", true)
            expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
          end
        end
      end

      describe "use_shell_script is false" do
        describe "upload command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
            expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command)
          end
        end

        describe "download command generation" do
          it 'generates a call to java directly' do
            transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
            expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command)
          end
        end
      end
    end

    describe "with Xcode 6.x installed", requires_xcode: true do
      before(:each) { allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('6.4') }

      describe "upload command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
        end
      end

      describe "download command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
        end
      end
    end

    describe "with Xcode 9.x installed", requires_xcode: true do
      before(:each) { allow(FastlaneCore::Helper).to receive(:xcode_version).and_return('9.1') }

      describe "upload command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.upload('my.app.id', '/tmp')).to eq(java_upload_command_9)
        end
      end

      describe "download command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.download('my.app.id', '/tmp')).to eq(java_download_command_9)
        end
      end
    end

    describe "with `FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT` set" do
      before(:each) do
        ENV["FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT"] = "1"
        allow(File).to receive(:exist?).with("C:/Program Files (x86)/itms").and_return(true) if FastlaneCore::Helper.windows?
      end

      describe "upload command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.upload('my.app.id', '/tmp')).to eq(shell_upload_command)
        end
      end

      describe "download command generation" do
        it 'generates a call to the shell script' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          expect(transporter.download('my.app.id', '/tmp')).to eq(shell_download_command)
        end
      end

      after(:each) { ENV.delete("FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT") }
    end

    describe "with no special configuration" do
      before(:each) do
        allow(File).to receive(:exist?).and_return(true) unless FastlaneCore::Helper.mac?
        ENV.delete("FASTLANE_ITUNES_TRANSPORTER_USE_SHELL_SCRIPT")
      end

      describe "upload command generation" do
        it 'generates the correct command' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          command = java_upload_command
          # If we are on Windows, switch to shell script command
          command = shell_upload_command if FastlaneCore::Helper.windows?
          # If we are on Mac with Xcode 6.x, switch to shell script command
          command = shell_upload_command if FastlaneCore::Helper.is_mac? && FastlaneCore::Helper.xcode_version.start_with?('6.')
          # If we are on Mac with Xcode >= 9, switch to newer java command
          command = java_upload_command_9 if FastlaneCore::Helper.is_mac? && FastlaneCore::Helper.xcode_at_least?(9)
          expect(transporter.upload('my.app.id', '/tmp')).to eq(command)
        end
      end

      describe "download command generation" do
        it 'generates the correct command' do
          transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
          command = java_download_command
          # If we are on Windows, switch to shell script command
          command = shell_download_command if FastlaneCore::Helper.windows?
          # If we are on Mac with Xcode 6.x, switch to shell script command
          command = shell_download_command if FastlaneCore::Helper.is_mac? && FastlaneCore::Helper.xcode_version.start_with?('6.')
          # If we are on Mac with Xcode >= 9, switch to newer java command
          command = java_download_command_9 if FastlaneCore::Helper.is_mac? && FastlaneCore::Helper.xcode_at_least?(9)
          expect(transporter.download('my.app.id', '/tmp')).to eq(command)
        end
      end
    end

    describe "with simulated no-test environment" do
      before(:each) do
        allow(FastlaneCore::Helper).to receive(:test?).and_return(false)
        @transporter = FastlaneCore::ItunesTransporter.new('fabric.devtools@gmail.com', "!> p@$s_-+=w'o%rd\"&#*<", false)
      end

      describe "and faked command execution" do
        it 'handles successful execution with no errors' do
          expect(FastlaneCore::FastlanePty).to receive(:spawn).and_return(0)
          expect(@transporter.upload('my.app.id', '/tmp')).to eq(true)
        end

        it 'handles exceptions' do
          expect(FastlaneCore::FastlanePty).to receive(:spawn).and_raise(StandardError, "It's all broken now.")
          expect(@transporter.upload('my.app.id', '/tmp')).to eq(false)
        end
      end
    end
  end
end
