require 'natto'
require 'enumerator'
require 'twitter'

client = Twitter::REST::Client.new(
  consumer_key:        '',
  consumer_secret:     '',
  access_token:        '',
  access_token_secret: '',
)

t = STDIN.read
$h = {}
$seeds = []

# マルコフ連鎖に使用するハッシュを作る
def parse_text(text)
  mecab = Natto::MeCab.new
  text = text.strip
  data = ['BEGIN', 'BEGIN']
  mecab.parse(text) do |a|
    if a.surface != nil
      data << a.surface
    end
  end
  data << 'END'
  data.each_cons(3).each do |a|
    suffix = a.pop
    prefix = a
    $h[prefix] ||= [] 
    $h[prefix] << suffix
  end
end

def markov()
  random = Random.new
  seeds_n = $seeds.length
  prefix = $h.to_a.sample[0]
  ret = ''
  num = 0
  loop{
    num += 1
    n = $h[prefix].length
    prefix = [prefix[1], $h[prefix][random.rand(0..n-1)]]
    ret += prefix[0] if prefix[0] && prefix[0] != 'BEGIN'
    if num == 30
      ret += prefix[1]
      break
    end
  }
  puts ret
  return ret
end

parse_text(t)
client.update(markov())
