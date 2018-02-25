require "audio-playback"
require "lame"
require "wavefile"
require "tempfile"

class MP3Player
  def self.play(wav_path)
    options = {
      :channels => [0,1],
      :latency => 1,
      :output_device => 1
    }
    playback = AudioPlayback.play(wav_path, options)
    playback.block
  end

  def self.decode_mp3(mp3_path)
    mp3_file =  File.open(mp3_path, "r")
    decoder = LAME::Decoder.new(mp3_file)
    format = WaveFile::Format.new(decoder.channel_mode, :pcm_16, decoder.sample_rate)
    tmp_wav = Tempfile.new('something inside-output.wav')
    WaveFile::Writer.new(tmp_wav.path, format) do |writer|
      decoder.each_decoded_frame do |decoded_frame|
        buffer = WaveFile::Buffer.new(decoded_frame.samples, format)
        writer.write(buffer)
      end
    end
    tmp_wav.path
  end
end

puts "MP3 Ruby Player"
puts "Enter mp3 file path"
mp3_path = gets.chomp
puts "Got it"
wav_path = MP3Player.decode_mp3(mp3_path)
MP3Player.play(wav_path)


