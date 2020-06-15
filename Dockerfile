FROM jekyll/jekyll

WORKDIR /srv/jekyll

COPY . /srv/jekyll

RUN chown -R jekyll:jekyll /srv/jekyll

ENTRYPOINT ["jekyll", "serve"]
