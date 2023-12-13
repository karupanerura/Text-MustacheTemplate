package Text::MustacheTemplate;
use 5.022000;
use strict;
use warnings;

our $VERSION = "0.01";

use Text::MustacheTemplate::Lexer;
use Text::MustacheTemplate::Parser;
use Text::MustacheTemplate::Compiler;

our $OPEN_DELIMITER;
our $CLOSE_DELIMITER;
our %REFERENCES;
our $LAMBDA_TEMPLATE_RENDERING = 0;

sub parse {
    my ($class, $source) = @_;
    local $Text::MustacheTemplate::Lexer::OPEN_DELIMITER = $OPEN_DELIMITER if defined $OPEN_DELIMITER;
    local $Text::MustacheTemplate::Lexer::CLOSE_DELIMITER = $CLOSE_DELIMITER if defined $CLOSE_DELIMITER;
    my @tokens = Text::MustacheTemplate::Lexer->tokenize($source);
    local $Text::MustacheTemplate::Parser::SOURCE = $source;
    my $ast = Text::MustacheTemplate::Parser->parse(@tokens);
    return Text::MustacheTemplate::Compiler->compile($ast);
}

sub render {
    my ($class, $source, $context) = @_;
    local @Text::MustacheTemplate::Compiler::CONTEXT_HINT = ($context);
    return $class->parse($source)->($context);
}

1;
__END__

=encoding utf-8

=head1 NAME

Text::MustacheTemplate - mustache template engine

=head1 SYNOPSIS

    use Text::MustacheTemplate;
    # local $Text::MustacheTemplate::OPEN_DELIMITER = '<%';
    # local $Text::MustacheTemplate::CLOSE_DELIMITER = '%>';

    my $rendered = Text::MustacheTemplate->render('* {{variable}}', { variable => 'foo' }); # => "* foo"

    my $template = Text::MustacheTemplate->parse('* {{variable}}');
    $rendered = $template->({ variable => 'foo' }); # => "* foo"
    $rendered = $template->({ variable => 'bar' }); # => "* bar"

=head1 DESCRIPTION

Text::MustacheTemplate is L<mustache|https://mustache.github.io/> template engine written in Pure Perl.

All features of Mustache Template are implemented. (e.g. inheritance, lambda, etc..)
And it is passed all L<mustache/spec|https://github.com/mustache/spec> test cases.

=head1 METHODS

=over 2

=item parse

Parses the template text. Returns a subroutine reference.
The subroutine receives one argument and processes the parsed template using the context variable specified in the argument.

    my $template = Text::MustacheTemplate->parse('* {{variable}}');
    $rendered = $template->({ variable => 'foo' }); # => "* foo"

This method is suitable for rendering the same template multiple times.

=item render

Render the template text using the context.
It returns a rendered text. 

    my $rendered_text = Text::MustacheTemplate->render($template_text, $context);

This method is suitable when the same template is rarely used.

=back

=head1 VARIABLES

Text::MustacheTemplate changes its behavior according to the following variables.
By using C<local>, this change can be localized.

=over 2

=item $OPEN_DELIMITER

This is the delimiter that opens the tag.
The default value is C<"{{">.

=item $CLOSE_DELIMITER

This is the delimiter that closes the tag.
The default value is C<"}}">.

=item %REFERENCES

This is references to other parsed templates.
It's used by inheritance or partial template feature.

=item $LAMBDA_TEMPLATE_RENDERING

When this flag is truthy, lambda template rendering is enabled.
The default value is falsey.

=back

=head1 BENCHMARK

    =============================
    parse
    =============================
    Benchmark: running Template::Mustache, Text::MustacheTemplate for at least 10 CPU seconds...
    Template::Mustache: 10 wallclock secs (10.36 usr +  0.00 sys = 10.36 CPU) @ 748.26/s (n=7752)
    Text::MustacheTemplate: 11 wallclock secs (10.49 usr +  0.02 sys = 10.51 CPU) @ 9560.04/s (n=100476)
                             Rate     Template::Mustache Text::MustacheTemplate
    Template::Mustache      748/s                     --                   -92%
    Text::MustacheTemplate 9560/s                  1178%                     --
    =============================
    render
    =============================
    Benchmark: running Template::Mustache, Text::MustacheTemplate for at least 10 CPU seconds...
    Template::Mustache: 11 wallclock secs (10.52 usr +  0.01 sys = 10.53 CPU) @ 729.34/s (n=7680)
    Text::MustacheTemplate: 11 wallclock secs (10.61 usr +  0.02 sys = 10.63 CPU) @ 30540.55/s (n=324646)
                              Rate     Template::Mustache Text::MustacheTemplate
    Template::Mustache       729/s                     --                   -98%
    Text::MustacheTemplate 30541/s                  4087%                     --
    =============================
    render (contextual optimization)
    =============================
    Benchmark: running disabled for at least 10 CPU seconds...
      disabled: 11 wallclock secs (10.51 usr +  0.02 sys = 10.53 CPU) @ 8941.41/s (n=94153)
                Rate disabled  enabled
    disabled  8941/s       --     -71%
    enabled  30541/s     242%       --
    =============================
    render(cached)
    =============================
    Benchmark: running Template::Mustache, Text::MustacheTemplate for at least 10 CPU seconds...
    Template::Mustache: 10 wallclock secs (10.40 usr +  0.02 sys = 10.42 CPU) @ 49247.02/s (n=513154)
    Text::MustacheTemplate: 11 wallclock secs (10.55 usr +  0.02 sys = 10.57 CPU) @ 230312.68/s (n=2434405)
                               Rate     Template::Mustache Text::MustacheTemplate
    Template::Mustache      49247/s                     --                   -79%
    Text::MustacheTemplate 230313/s                   368%                     --

=head1 SEE ALSO

L<Template::Mustache> L<Mustache::Simple>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

