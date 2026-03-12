class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "84002d6f5a3e5a4d33bb94e07196eafa45f1de8faf86a55d34c186cc646034c8"
  license "MIT"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "swift", "build", "-c", "release", "--disable-sandbox"

      # Debug: list build output
      system "find", ".build", "-name", "NgrokTools", "-type", "f"
      system "ls", "-la", ".build/release/" if File.directory?(".build/release")
      system "ls", "-la", ".build/" if File.directory?(".build")

      # Try multiple possible paths
      candidates = Dir[".build/**/release/NgrokTools"].select { |f| File.executable?(f) && !f.include?("NgrokTools.build") && !f.include?("dSYM") }
      ohai "Found candidates: #{candidates.inspect}"

      if candidates.empty?
        odie "Could not find NgrokTools binary in .build/"
      end

      binary = candidates.first
      bin_dir = File.dirname(binary)
      ohai "Using binary: #{binary}"

      bin.install binary => "ngrok-toolbar"

      # Create app bundle
      app_dir = prefix/"NgrokToolbar.app"
      app_contents = app_dir/"Contents"
      (app_contents/"MacOS").mkpath
      (app_contents/"Resources").mkpath

      cp binary, app_contents/"MacOS/NgrokTools"
      cp "Info.plist", app_contents/"Info.plist"

      if File.exist?("AppIcon.icns")
        cp "AppIcon.icns", app_contents/"Resources/AppIcon.icns"
      end

      resource_bundle = "#{bin_dir}/NgrokTools_NgrokTools.bundle"
      if File.directory?(resource_bundle)
        cp_r resource_bundle, app_dir/"NgrokTools_NgrokTools.bundle"
      end
    end
  end

  def caveats
    <<~EOS
      To start ngrok-toolbar:
        open #{prefix}/NgrokToolbar.app

      Or run directly:
        ngrok-toolbar

      You need an ngrok API Key (not authtoken):
        https://dashboard.ngrok.com/api-keys
    EOS
  end

  test do
    assert_predicate bin/"ngrok-toolbar", :exist?
  end
end
