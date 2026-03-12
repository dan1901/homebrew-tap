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
      bin.install ".build/release/NgrokTools" => "ngrok-toolbar"

      # Install resource bundle
      resource_bundle = ".build/release/NgrokTools_NgrokTools.bundle"
      if File.directory?(resource_bundle)
        (lib/"NgrokTools_NgrokTools.bundle").install Dir["#{resource_bundle}/*"]
      end
    end

    # Create app bundle
    app_bundle = prefix/"NgrokToolbar.app/Contents"
    (app_bundle/"MacOS").mkpath
    (app_bundle/"Resources").mkpath
    cp bin/"ngrok-toolbar", app_bundle/"MacOS/NgrokTools"
    cp "NgrokTools/Info.plist", app_bundle/"Info.plist"

    # Copy icons
    if File.exist?("NgrokTools/AppIcon.icns")
      cp "NgrokTools/AppIcon.icns", app_bundle/"Resources/AppIcon.icns"
    end

    # Resource bundle at .app/ root (where SPM's Bundle.module looks)
    resource_bundle = "NgrokTools/.build/release/NgrokTools_NgrokTools.bundle"
    if File.directory?(resource_bundle)
      cp_r resource_bundle, prefix/"NgrokToolbar.app/"
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
