node default {
  if $facts["hostname"] =~ /choria-nats/ {
    include nats
  }

  if $facts["hostname"] =~ /choria/ {
    include mcollective

    user{"mcuser":
      ensure => "present",
      managehome => true
    }

    file{"/usr/bin/mco":
      target     => "/opt/puppetlabs/bin/mco"
    }
  }
}
