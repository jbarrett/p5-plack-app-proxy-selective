use strict;
use warnings;

use Test::Most;
use Path::Class;

use Plack::App::Proxy::Selective;


subtest 'test with normal string filter' => sub {

    my $selective = Plack::App::Proxy::Selective->new(
        filter => +{
            'google.com' => +{
                '/script' => '/js',
                'js' => '/js',
            }
        },
        base_dir => file(__FILE__)->dir,
    );

    dies_ok {
        $selective->call(+{});
    } 'selective requires env with HTTP_HOST and REQUEST_URI';

    lives_ok {
        $selective->call(+{ 'HTTP_HOST' => 'google.com', 'REQUEST_URI' => 'http://google.com/script/test.js' });
    } 'selective maps absolute uri to local dir';

    lives_ok {
        $selective->call(+{ 'HTTP_HOST' => 'google.com', 'REQUEST_URI' => 'http://google.com/js/test.js' });
    } 'selective maps relative uri to local dir';


    done_testing;
};


subtest 'test with regex filter' => sub {

    my $selective = Plack::App::Proxy::Selective->new(
        filter => +{
            'google.com' => +{
                '/css/js.*/' => '/style/',
                '/script/.*' => '/js/ext/',
            }
        },
        base_dir => file(__FILE__)->dir,
    );

    lives_ok {
        $selective->call(+{ 'HTTP_HOST' => 'google.com', 'REQUEST_URI' => 'http://google.com/script/test.js' });
    } 'selective maps ended-with-star uri to local dir';

    lives_ok {
        $selective->call(+{ 'HTTP_HOST' => 'google.com', 'REQUEST_URI' => 'http://google.com/script/hoge/test.js' });
    } 'selective maps ended-with-star uri to local dir recursively';



    done_testing;
};

done_testing;
