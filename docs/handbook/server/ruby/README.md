
cd /usr/local/src
wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
tar xvzf ruby-2.2.2.tar.gz
cd ruby-2.2.2
./configure --prefix=/usr/local/ruby
make && make install

cat /etc/profile.d/ruby-evn.sh
export RUBY_HOME=/usr/local/ruby
export PATH=$RUBY_HOME/bin:$PATH

gem sources -l
gem sources -a http://ruby.taobao.org
gem sources -r https://rubygems.org/

gem install redis
gem list

gem install bundle




