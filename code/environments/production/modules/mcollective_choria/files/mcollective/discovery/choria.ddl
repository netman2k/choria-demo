metadata    :name        => "choria",
            :description => "PuppetDB based discovery for the Choria plugin suite",
            :author      => "R.I.Pienaar <rip@devco.net>",
            :license     => "Apache-2.0",
            :version     => "0.0.1",
            :url         => "https://github.com/ripienaar/mcollective-choria",
            :timeout     => 0

discovery do
    capabilities [:classes, :facts, :identity, :agents]
end
