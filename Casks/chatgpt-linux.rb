cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.908.31748"
  sha256 arm64_linux:  "de6117d4372d12af6510bf8dcf1dfcefa0ebea9f11894d564a3af739b3ed4258",
         x86_64_linux: "2df54c70c7c86042e1b525fb123188e9fcd1e7993e4a77ed0e93f250b2d80685"

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
