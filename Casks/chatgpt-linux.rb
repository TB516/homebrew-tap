cask "chatgpt-linux" do
  arch arm: "arm64", intel: "amd64"

  version "26.810.50856"
  sha256 arm64_linux:  "ab851b2eb73374229f8daa17993d06c9d031094d0eeac5e7f4e02c072a110f62",
         x86_64_linux: "e3b47c1298e01e4a2aa54f120eb169834c6911bd295122bc43e5cd1642c1a4ba"

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
