This stands up a Puppet Server, PostgreSQL, PuppetDB cluster using docker compose and then let you join centos instances to it to bootstrap mcollective choria

It only works really on recent CentOS or maybe Ubuntu as docker host since you need to mount `/sys/fs/cgroup:/sys/fs/cgroup:ro` in for systemd to work

```
$ docker-compose up
```

Wait for it to go idle and stop spewing in logs

Now start instances for NATS and for CentOS, you can start multiple of the `choria1` like instances

```
$ docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --net choriademo_default -h choria-nats1.example.net -d --name nats -v `pwd`/bootstrap-puppet.sh:/bootstrap-puppet.sh centos/systemd
$ docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --net choriademo_default -h choria1.example.net -d --name choria1 -v `pwd`/bootstrap-puppet.sh:/bootstrap-puppet.sh --link puppetdb:puppetdb.example.net centos/systemd
```

Then puppet bootstrap each, nats first:

```
$ docker exec -ti nats /bootstrap-puppet.sh
$ docker exec -ti choria1 /bootstrap-puppet.sh
```

now get the cert for the `mcuser`

```
$ docker exec -ti choria1 bash
# su - mcuser
$ mco choria request_cert
$ mco puppet status
$ mco puppet summary
$ mco service puppet status
$ mco package puppet-agent status
```

