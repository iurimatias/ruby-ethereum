require 'spec_helper'

describe Buffer do
  describe "#receive_data" do
    before do
      @buffer = Buffer.new
    end

    describe "receiving 1 package" do
      it "should return 1 package" do
        expect(@buffer).to receive(:trigger).once
        @buffer.receive simple_package
      end
    end

    describe "receiving a part of a package" do
      it "should return 0 packages" do
        expect(@buffer).to_not receive(:trigger)
        @buffer.receive package_part1
      end
    end

    describe "receiving a part of a package + the rest in the next request" do
      it "should return 1 packages" do
        expect(@buffer).to receive(:trigger).once
        @buffer.receive package_part1
        @buffer.receive package_part2
      end
    end

    describe "receiving 2 packages and a part of a package" do
      it "should return 2 packages" do
        expect(@buffer).to receive(:trigger).twice
        @buffer.receive simple_package + simple_package + package_part1
      end
    end
  end

  describe "#extra_data" do
    before do
      @buffer = Buffer.new
    end

    describe "sync_code|size|data" do
      it "should return 1 package" do
        packages = @buffer.extract_packages(simple_package)
        expect(packages.size).to be(1)
      end
    end

    describe "sync_code|size|data|sync_code|size|data" do
      it "should return 2 package" do
        packages = @buffer.extract_packages(simple_package*2)
        expect(packages.size).to be(2)
      end
    end

    describe "sync_code|size|data|sync_code|size|incomplete_data" do
      before do
        @packages = @buffer.extract_packages(simple_package*2 + package_part1)
      end

      it "should return 2 package" do
        expect(@packages.size).to be(2)
      end

      it "should store the remaining data in the buffer" do
        expect(@buffer.buffer).to eq(package_part1)
      end
    end

    describe "buffer_data + data|sync_code|size|incomplete_data" do
      before do
        @buffer.buffer = package_part1
        @packages = @buffer.extract_packages(package_part2 + package_part1)
      end

      it "should return 1 package" do
        expect(@packages.size).to be(1)
      end

      it "should store the remaining data in the buffer" do
        expect(@buffer.buffer).to eq(package_part1)
      end
    end

    describe "buffer_data + data" do
      before do
        @buffer.buffer = package_part1
        @packages = @buffer.extract_packages("data")
      end

      it "should return 1 package" do
        expect(@packages.size).to be(0)
      end

      it "should store the remaining data in the buffer" do
        expect(@buffer.buffer).to eq(package_part1 + "data")
      end
    end
  end

end
