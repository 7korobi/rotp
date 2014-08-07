describe "ROTP::TOTP" do
  before do
    @now = Time.utc(2012, 1, 1)
    @subject = ROTP::TOTP.new("JBSWY3DPEHPK3PXP")
  end

  it "should generate a number given a number" do
    @subject.at(@now, false).should == 68212
  end

  it "should generate a number as a padded string by default" do
    @subject.at(@now).should == "068212"
  end

  # Users of the lib
  it "should not verify a number" do
    should.raise(ArgumentError) {
      @subject.verify(68212, @now)
    }
  end
  it "should not verify an unpadded string" do
    @subject.verify("68212", @now).should.be.false
  end
  it "should verify a string" do
    @subject.verify("068212", @now).should.be.true
  end
#
#   it "should output its provisioning URI" do
#     url = subject.provisioning_uri('mark@percival')
#     params = CGI::parse(URI::parse(url).query)
#     url.should match(/otpauth:\/\/totp.+/)
#     params["secret"].first.should == "JBSWY3DPEHPK3PXP"
#   end
#
#   context  "with issuer" do
#     subject { ROTP::TOTP.new("JBSWY3DPEHPK3PXP", :issuer => "FooCo") }
#     it "should output its provisioning URI with issuer" do
#       url = subject.provisioning_uri('mark@percival')
#       params = CGI::parse(URI::parse(url).query)
#       url.should match(/otpauth:\/\/totp.+/)
#       params["secret"].first.should == "JBSWY3DPEHPK3PXP"
#       params["issuer"].first.should == "FooCo"
#     end
#   end
#
#   context  "with non default interval" do
#     subject { ROTP::TOTP.new("JBSWY3DPEHPK3PXP", :interval => 60) }
#     it "should output its provisioning URI with issuer" do
#       url = subject.provisioning_uri('mark@percival')
#       params = CGI::parse(URI::parse(url).query)
#       url.should match(/otpauth:\/\/totp.+/)
#       params["secret"].first.should == "JBSWY3DPEHPK3PXP"
#       params["period"].first.should == "60"
#     end
#   end
#
#
  context "with drift" do
    it "should verify a number" do
      @subject.verify_with_drift("068212", 0, @now).should.be.true
    end
    it "should verify a string" do
      @subject.verify_with_drift("068212", 0, @now).should.be.true
    end
    it "should verify a slightly old number" do
      @subject.verify_with_drift(@subject.at(@now - 30), 60, @now).should.be.true
    end
    it "should verify a slightly new number" do
      @subject.verify_with_drift(@subject.at(@now + 60), 60, @now).should.be.true
    end
    it "should reject a number that is outside the allowed drift" do
      @subject.verify_with_drift(@subject.at(@now - 60), 30, @now).should.be.false
    end
    context "with drift that is not a multiple of the TOTP interval" do
      it "should verify a slightly old number" do
        @subject.verify_with_drift(@subject.at(@now - 45), 45, @now).should.be.true
      end
      it "should verify a slightly new number" do
        @subject.verify_with_drift(@subject.at(@now + 40), 40, @now).should.be.true
      end
    end
  end
end

describe "TOTP example values from the documented output" do
  it "should match the RFC" do
    totp = ROTP::TOTP.new("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
    totp.at(1111111111).should ==("050471")
    totp.at(1234567890).should ==("005924")
    totp.at(2000000000).should ==("279037")
  end

  it "should match the Google Authenticator output" do
    totp = ROTP::TOTP.new("wrn3pqx5uqxqvnqr")
    totp.at(1297553958).should ==("102705")
  end
  it "should match Dropbox 26 char secret output" do
    totp = ROTP::TOTP.new("tjtpqea6a42l56g5eym73go2oa")
    totp.at(1378762454).should ==("747864")
  end
  it "should validate a time based OTP" do
    totp = ROTP::TOTP.new("wrn3pqx5uqxqvnqr")
    totp.at(Time.at(1297553958)).should ==("102705")
    totp.at(Time.at(1297553958 + 30)).should !=("102705")
  end
end
