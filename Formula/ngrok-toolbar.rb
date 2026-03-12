class NgrokToolbar < Formula
  desc "macOS menu bar app for managing ngrok tunnels, sessions, and endpoints"
  homepage "https://github.com/dan1901/ngrok-toolbar"
  url "https://github.com/dan1901/ngrok-toolbar/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "a15a3405e37e6cf5de6b3c0e1409f08dc81d12747999cf87ac67b492ce28f6df"
  license "MIT"
  head "https://github.com/dan1901/ngrok-toolbar.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos => :sonoma

  def install
    cd "NgrokTools" do
      system "swift", "build", "-c", "release", "--disable-sandbox"

      # Copy build outputs - use arch-specific path (symlink .build/release may not work in sandbox)
      arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
      system "cp", ".build/#{arch}-apple-macosx/release/NgrokTools", "NgrokTools-bin"
      system "cp", "-R", ".build/#{arch}-apple-macosx/release/NgrokTools_NgrokTools.bundle", "NgrokTools_NgrokTools.bundle"

      bin.install "NgrokTools-bin" => "ngrok-toolbar"

      # Create app bundle
      app_dir = prefix/"NgrokToolbar.app"
      app_contents = app_dir/"Contents"
      (app_contents/"MacOS").mkpath
      (app_contents/"Resources").mkpath

      cp "NgrokTools-bin", app_contents/"MacOS/NgrokTools"
      cp "Info.plist", app_contents/"Info.plist"

      if File.exist?("AppIcon.icns")
        cp "AppIcon.icns", app_contents/"Resources/AppIcon.icns"
      end

      # Resource bundle at .app/ root (where SPM's Bundle.module looks)
      if File.directory?("NgrokTools_NgrokTools.bundle")
        cp_r "NgrokTools_NgrokTools.bundle", app_dir/"NgrokTools_NgrokTools.bundle"
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
