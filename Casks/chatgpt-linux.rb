cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.908.40401"
  sha256 arm64_linux:  "e5659fb815802c91ec10bad9341130518e0cdf3d9cb81784c1293589edaae0a1",
         x86_64_linux: "7c089bda20728723e7ad16b7295198ddce14afd53e03f8a48f6735449f48cd03"

  url "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_#{version}_#{arch}.deb"
  name "ChatGPT"
  desc "AI assistant from OpenAI"
  homepage "https://openai.com/chatgpt/desktop/"

  livecheck do
    url "https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-#{arch}/Packages"
    regex(/^Version:\s*v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on :linux
  container type: :naked

  rename "chatgpt_#{version}_#{arch}.deb", "chatgpt.deb"

  binary "usr/lib/chatgpt/codex-launcher", target: "chatgpt"
  artifact "usr/share/applications/chatgpt.desktop",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/applications/chatgpt.desktop"
  artifact "usr/share/pixmaps/chatgpt.png",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/512x512@2/apps/chatgpt.png"

  preflight_steps do
    run "ar", args: ["x", "chatgpt.deb", "data.tar.xz"], chdir: "."
    run "tar", args: ["-xf", "data.tar.xz"], chdir: "."

    inreplace "usr/share/applications/chatgpt.desktop", /^Exec=.*$/, "Exec={{HOMEBREW_PREFIX}}/bin/chatgpt %U"
  end

  zap trash: ENV["CODEX_ELECTRON_USER_DATA_PATH"] ||
             "#{ENV["XDG_CONFIG_HOME"] || "#{Dir.home}/.config"}/Codex"
end
