require File.dirname(__FILE__) + '/../../lib/empythree'
require File.dirname(__FILE__) + '/../common_helpers'

include CommonHelpers

describe Empythree::XingHeader do
  it 'raises an error if the first 4 bytes don\'t say "Xing"' do
    io = StringIO.new("Ping\x00\x00\x00\x00")
    expect { Empythree::XingHeader.new(io) }.to raise_error(Empythree::InvalidXingHeaderError)
  end

  it 'raises an error if the next int is more than 15' do
    io = StringIO.new("Xing\x00\x00\x00\x10")
    expect { Empythree::XingHeader.new(io) }.to raise_error(Empythree::InvalidXingHeaderError)
  end

  describe "with no parts" do
    subject { Empythree::XingHeader.new(StringIO.new("Xing\x00\x00\x00\x00")) }
    its(:frames)  { is_expected.to be_nil }
    its(:bytes)   { is_expected.to be_nil }
    its(:toc)     { is_expected.to be_nil }
    its(:quality) { is_expected.to be_nil }
  end

  describe "with only a frame count" do
    subject { Empythree::XingHeader.new(StringIO.new("Xing\x00\x00\x00\x01\x00\x00\x14\xFA")) }
    its(:frames)  { is_expected.to eq(5370) }
    its(:bytes)   { is_expected.to be_nil }
    its(:toc)     { is_expected.to be_nil }
    its(:quality) { is_expected.to be_nil }
  end

  describe "with only a byte count" do
    subject { Empythree::XingHeader.new(StringIO.new("Xing\x00\x00\x00\x02\x00\x00\x14\xFA")) }
    its(:frames)  { is_expected.to be_nil }
    its(:bytes)   { is_expected.to eq(5370) }
    its(:toc)     { is_expected.to be_nil }
    its(:quality) { is_expected.to be_nil }
  end

  describe "with only a TOC" do
    subject { Empythree::XingHeader.new(StringIO.new("Xing\x00\x00\x00\x04" + ("\x00" * 100))) }
    its(:frames)  { is_expected.to be_nil }
    its(:bytes)   { is_expected.to be_nil }
    its(:toc)     { is_expected.to eq([ 0 ] * 100) }
    its(:quality) { is_expected.to be_nil }
  end

  describe "with only a quality" do
    subject { Empythree::XingHeader.new(StringIO.new("Xing\x00\x00\x00\x08\x00\x00\x00\x55")) }
    its(:frames)  { is_expected.to be_nil }
    its(:bytes)   { is_expected.to be_nil }
    its(:toc)     { is_expected.to be_nil }
    its(:quality) { is_expected.to eq(85) }
  end

  describe "with all four" do
    subject do
      str = [ 
        'Xing', # ID
        "\x00\x00\x00\x0F", # Which fields are present
        "\x00\x4B\xF4\x80", # The frame count
        "\x00\x1C\x7B\xB0", # The byte count
        "\x00" * 100,       # The TOC
        "\x00\x00\x00\x55",  # The quality
      ].join('')
      Empythree::XingHeader.new(StringIO.new(str))
    end

    its(:frames)  { is_expected.to eq(4977792) }
    its(:bytes)   { is_expected.to eq(1866672) }
    its(:toc)     { is_expected.to eq([ 0 ] * 100) }
    its(:quality) { is_expected.to eq(85) }
  end
end
