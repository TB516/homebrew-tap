cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.814.41957"
  sha256 arm64_linux:  "8c40b31419dd4f4a8eb292d40dc3f8a418807dfe8c0101ae7164fa4ee415f818",
         x86_64_linux: "4778b26a7abd08647214d5b05c17bd3ebe2d9688d146dabf017c1a2faf93ac7d"

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
