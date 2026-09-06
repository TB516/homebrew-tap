cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.901.51231"
  sha256 arm64_linux:  "02a2f5c6cb69509c62abcbdd13c76b139cdb2ca9edde7537239ddde024077ea0",
         x86_64_linux: "62580188d87c3d3a9369dab7c73b42a8a32518d4df8a2d5bae6466ddeac5c05e"

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
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/1024x1024/apps/chatgpt.png"

  preflight_steps do
    run "ar", args: ["x", "chatgpt.deb", "data.tar.xz"], chdir: "."
    run "tar", args: ["-xf", "data.tar.xz"], chdir: "."

    inreplace "usr/share/applications/chatgpt.desktop", /^Exec=.*$/, "Exec={{HOMEBREW_PREFIX}}/bin/chatgpt %U"
  end

  zap trash: ENV["CODEX_ELECTRON_USER_DATA_PATH"] ||
             "#{ENV["XDG_CONFIG_HOME"] || "#{Dir.home}/.config"}/Codex"
end
