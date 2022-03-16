# frozen_string_literal: true

RSpec.describe Peartree::Encoder do
  subject(:call) { described_class.new(input, format:).call }

  let(:format) { nil }

  include_context 'with mocked lexicon'

  shared_examples 'success' do
    it 'returns expected output' do
      expect(call).to eq(output)
    end
  end

  shared_examples 'invalid format' do
    it 'raises an exception' do
      expect { call }.to raise_error(Peartree::InvalidFormat)
    end
  end

  context 'with invalid input' do
    context 'when invalid hex chars' do
      let(:input) { '23az939fs2' }

      include_examples 'invalid format'
    end

    context 'when input is too long' do
      let(:input) do
        <<~TEXT
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end

      it 'raises an exception' do
        expect { call }.to raise_error(Peartree::InputTooLarge)
      end
    end

    context 'when invalid decimal chars' do
      let(:input) { '' }
      let(:dec) { '34234abc2342' }

      include_examples 'invalid format'
    end

    context 'when invalid bin chars' do
      let(:input) { '' }
      let(:dec) { '010010abc10101' }

      include_examples 'invalid format'
    end
  end

  context 'with valid input' do
    let(:output) do
      <<~TEXT.strip
        In #{Peartree::VERSION_SLUG} at 6pm I saw
        six adjectiveago noundcs verbmd an adjectivesd noundd,
        five adjectivealm nounmds verbaji an adjectivevm nounqo,
        four adjectiveol nounaags verbadb an adjectiveaew nounqq,
        three adjectiveale nounacjs verbagz an adjectiverf nounth,
        two adjectivekn nounhws verbhu an adjectivest nounry,
        and an adjectivewi nounbh
      TEXT
    end

    context 'when input is in hexidecimal format' do
      let(:input) do
        <<~TEXT
          da46b559f21b3e955bb1925c964ac5c3b3d72fe1bf37476a104b0e7396027b65
        TEXT
      end

      include_examples 'success'
    end

    context 'when input is in binary format' do
      let(:input) do
        <<~TEXT
          1101101001000110101101010101100111110010000110110011111010010101010110111011000110010010010111001001011001001010110001011100001110110011110101110010111111100001101111110011011101000111011010100001000001001011000011100111001110010110000000100111101101100101
        TEXT
      end
      let(:format) { :bin }

      include_examples 'success'
    end

    context 'when input is in decimal format' do
      let(:input) do
        <<~TEXT
          98729131926707364344155946614204368554393612909660450514900410658357640330085
        TEXT
      end
      let(:format) { :dec }

      include_examples 'success'
    end
  end

  context 'with short input and partial last phrase' do
    let(:output) do
      <<~TEXT.strip
        In #{Peartree::VERSION_SLUG} at 8pm I saw an adjectiveago noundc verbme a nounhp
      TEXT
    end
    let(:input) { 'da46b55' }

    include_examples 'success'
  end

  context 'when input divides evenly' do
    let(:output) do
      <<~TEXT.strip
        In #{Peartree::VERSION_SLUG} I saw an adjectiveami nounafk
      TEXT
    end
    let(:input) { '3ff' }

    include_examples 'success'
  end
end
