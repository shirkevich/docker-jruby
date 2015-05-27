FROM phusion/baseimage:latest

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


#Install Oracle JDK 8
RUN sudo add-apt-repository ppa:webupd8team/java && sudo apt-get update
#This absurdity exists so that JDK is installed without prompting for license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

#tools
RUN apt-get update
RUN apt-get install -y postgresql-client git mysql-client vim zsh python python-pip curl tmux wget
RUN sudo apt-get install -y --no-install-recommends oracle-java8-installer
RUN sudo apt-get install oracle-java8-set-default
RUN pip install Jinja2
RUN pip install j2cli
RUN sudo apt-get autoremove -y && apt-get clean

#install cacert cert
RUN mkdir /usr/local/share/ca-certificates/cacert.org
RUN wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
RUN update-ca-certificates

ENV JRUBY_VERSION 1.7.20
#Get JRuby
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt

ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH

RUN echo gem: --no-document >> /etc/gemrc

RUN gem update --system
RUN gem install bundler

#Add user
RUN addgroup --gid 9999 deploy
RUN adduser --uid 9999 --gid 9999 --disabled-password --gecos "Deployer" deploy
RUN usermod -L deploy
RUN mkdir -p /home/deploy/
#ADD . /home/deploy
RUN chown -R deploy:deploy /home/deploy/

USER deploy

#JRuby options
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
RUN echo compat.version=2.0 > /home/deploy/.jrubyrc
RUN echo invokedynamic.all=true >> /home/deploy/.jrubyrc

#Get Rails running
#WORKDIR /home/app/my_app
#ENV RAILS_ENV staging
#RUN bundle exec rake db:reset
#RUN bundle install --deployment --without test development
##################################################################
#Remove these lines when using fig since fog will start the server
##################################################################
#RUN bundle exec rake db:reset
#EXPOSE 3000
#ENTRYPOINT bundle exec rails server
