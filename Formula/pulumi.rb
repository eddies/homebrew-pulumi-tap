class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://pulumi.io/"
  url "https://get.pulumi.com/releases/sdk/pulumi-v2.1.0-alpha.1588034617-darwin-x64.tar.gz"
  version "2.1.0-alpha.1588034617"
  sha256 "54f412fc8e28016b7f4627b52606f6f623c02f40433b287593b68501d4852812"

  bottle :unneeded

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    dir = buildpath/"src/github.com/pulumi/pulumi"
    dir.install buildpath.children

    cd dir do
      cd "./sdk" do
        system "go", "mod", "download"
      end
      cd "./pkg" do
        system "go", "mod", "download"
      end
      system "make", "dist"
      bin.install Dir["#{buildpath}/bin/*"]
      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion bash")
      (bash_completion/"pulumi").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion zsh")
      (zsh_completion/"_pulumi").write output
    end
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_TEMPLATE_PATH"] = testpath/"templates"
    system "#{bin}/pulumi", "new", "aws-typescript", "--generate-only",
                                                     "--force", "-y"
    assert_predicate testpath/"Pulumi.yaml", :exist?, "Project was not created"
  end
end
