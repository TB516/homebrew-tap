cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.908.61612"
  sha256 arm64_linux:  "f70ada5699828fdf68f007ef922e1a639f7e4413724525c7459698bc4819d6d9",
         x86_64_linux: "1e4b1896cd5694db667022ada8580455833223027a2944409cb4b535e7b5485e"

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
