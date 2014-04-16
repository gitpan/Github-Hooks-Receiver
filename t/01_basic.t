use strict;
use warnings;
use utf8;

use Test::More 0.98;
use Plack::Test;
use HTTP::Request::Common;

use Github::Hooks::Receiver;

my $counter;

my $receiver = Github::Hooks::Receiver->new;

$receiver->on(sub {
    $counter++;
});

$receiver->on(hoge => sub {
    $counter++;
});

my $app = $receiver->to_app;

test_psgi $app => sub {
    my $cb  = shift;

    my $req = POST '/', [
        payload => '{"hoge":"fuga"}',
    ], 'X-GitHub-Event' => 'hoge';

    my $res = $cb->($req);
    is $res->content, 'OK';
    is $counter, 2;

    $req = POST '/', [
        payload => '{"hoge":"fuga"}',
    ], 'X-GitHub-Event' => 'piyo';
    $res = $cb->($req);
    is $res->content, 'OK';
    is $counter, 3;
};

done_testing;
