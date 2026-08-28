cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.820.80927"
  sha256 arm64_linux:  "ec41099d416ddbd5e803d4a9b7aa33a68b5ce63998f6a2f6f069d4bb948c0921",
         x86_64_linux: "09efdcd0651fda2aaa3457a1b0929504a5de8ebcc4e629ed8cfebe34e98a49f8"

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

  binary "usr/lib/chatgpt/codex-launcher", target: "chatgpt"
  artifact "usr/share/applications/chatgpt.desktop",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/applications/chatgpt.desktop"
  artifact "usr/share/pixmaps/chatgpt.png",
           target: "#{ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"}/icons/hicolor/1024x1024/apps/chatgpt.png"

  preflight do
    deb_name = "chatgpt_#{version}_#{arch}.deb"

    Dir.chdir(staged_path) do
      system("ar", "x", deb_name, "data.tar.xz")
      system("tar", "-xf", "data.tar.xz")
    end

    xdg_data_home = ENV["XDG_DATA_HOME"] || "#{Dir.home}/.local/share"
    FileUtils.mkdir_p("#{xdg_data_home}/applications")
    FileUtils.mkdir_p("#{xdg_data_home}/icons/hicolor/1024x1024/apps")

    desktop_file = "#{staged_path}/usr/share/applications/chatgpt.desktop"
    desktop_contents = File.read(desktop_file)
    desktop_contents.gsub!(/^Exec=.*$/, "Exec=#{HOMEBREW_PREFIX}/bin/chatgpt %U")
    File.write(desktop_file, desktop_contents)
  end

  zap trash: ENV["CODEX_ELECTRON_USER_DATA_PATH"] ||
             "#{ENV["XDG_CONFIG_HOME"] || "#{Dir.home}/.config"}/Codex"
end
