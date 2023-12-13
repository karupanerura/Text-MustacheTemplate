requires 'Exporter', '5.57';
requires 'HTML::Escape';
requires 'List::Util';
requires 'Scalar::Util';
requires 'perl', '5.022000';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'JSON::PP';
    requires 'Test::Base::Less';
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'Template::Mustache';
    requires 'feature';
};
