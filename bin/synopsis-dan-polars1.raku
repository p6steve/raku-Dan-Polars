#!/usr/bin/env raku

use lib '../lib';

use Dan;
use Dan::Polars;

my \s = $;
#my $index = {:a(0), :b(1), :c(2), :d(3), :e(4), :f(5)};
#s = Series.new(data => [1, 3, 5, NaN, 6, 8], :$index, name => 'john' );
#s = Series.new(data => [1, 3, 5, NaN, 6, 8], index => <a b c d e f>, name => 'john' );
#s = Series.new(data => [1, 3, 5, NaN, 6, 8]);
#s = Series.new([1, 3, 5, 6, 8]);
#s = Series.new([1, 3, 5, NaN, 6, 8]);
s = Series.new( [b=>1, a=>0, c=>2] );               #from Array of Pairs
#s = Series.new( [rand xx 6], index => <a b c d e f>);

#s = Series.new(data => [1, 3, 5, 6, 8], name => 'john' );                          #i32
#s = Series.new(data => [1, 3, 5, 6, 4_294_967_294], name => 'john' );              #u32
#s = Series.new(data => [-1, 3, 5, 6, 4_294_967_298], name => 'john' );             #i64
#s = Series.new(data => [1, 3, 5, 6, 18_446_744_073_709_551_614], name => 'john' ); #u64
#s = Series.new(data => [1, 3, 5, 6, 8], name => 'john', dtype => 'num32' );        #f32
#s = Series.new(data => [1, 3, 5, NaN, 6, 8], name => 'john' );                     #f64
#s = Series.new(data => <a b c d e f>, name => 'anna' );                            #str
#s = Series.new(data => [True, False, True, False], name => 'john' );               #bool

#s = Series.new(data => 'a'..'z', name => 'anna' );                            #str
#s = Series.new(data => 1..99, name => 'john' );                          #i32

#say ~s;
s.show;
#`[[
s.head;
say s.dtype;
say s.name;
say s.elems;
s.values;
my \sd = s.Dan-Series;
dd sd;
s.pull;
say s.data;
say s.index;
say s.ix;
#say ~s.reindex(['d','e','f','g','h','i']);
say s.map(*+2);
say [+] s; 
say s >>+>> 2; 
say s >>+<< s; 
say s[2];
#say s<c>;

s.splice(1,2,(j=>3)); 
my \t = Series.new( [f=>1, e=>0, d=>2] );
s.concat: t;
s.head;

my \quants = Series.new([100, 15, 50, 15, 25]);
quants.show;
my \prices = Series.new([1.1, 4.3, 2.2, 7.41, 2.89]);
prices.show;
my \costs  = Series.new( quants >>*<< prices );
costs.show;

my \u = s.Dan-Series;
say u.^name;
say ~u;

my \v = Series.new( u );
say v.^name;
v.show;

#`[ expression (part of df query vvvvv) 
my \costs = quants;
costs.pd: '.mul', prices;
#]

#]]

say "=============================================";

### DataFrames ###

#my \dates = (Date.new("2022-01-01"), *+1 ... *)[^6];
#my \df = DataFrame.new( [[rand xx 4] xx 6], index => dates, columns => <A B C D> );
#my \df = DataFrame.new( [[rand xx 4] xx 6], columns => <A B C D> );
#my \df = DataFrame.new( [[rand xx 4] xx 6] );

#`[
my \df = DataFrame.new;
df.read_csv("../dan/src/iris.csv");
my $column = df.column("sepal.length");
$column.head;
my $select = df.select(["sepal.length", "variety"]);
$select.head;
#]

#`[
#my \df = DataFrame.new();
#df.with_column(s);  ##moved to lf
##say ~df;
df.show;
df.head;
say df.elems;
say df.dtypes;
say df.get_column_names;
say df.cx;
df.pull; 
say df.data;
#]

#FIXME (cascading accessors - see PCF redesign text edit - move type to given / when!?)
#FIXME (have left in state Role Support on, postcircumfix etc off 
say "---------------------------------------------";

# Data Accessors [row;col]
#say df[0;0];
##df[0;0] = 3;                # set value (not sure why this works, must manual push

#`[
# Smart Accessors (mix Positional and Associative)
say df[0];
say df[0][0];
say df ~~ DataFrame:D;
say df[0]<A>; #... hmm broken!;
#say df{"2022-01-03"}[1];
# Object Accessors & Slices (see note 1)
say ~df[0];                 # 1d Row 0 (DataSlice)
say ~df[*]<A>;              # 1d Col A (Series)
say ~df[0..*-2][1..*-1];    # 2d DataFrame
#say ~df{dates[0..1]}^;      # the ^ postfix converts an Array of DataSlices into a new DataFrame
# Head & Tail
say ~df[0..^3]^;            # head
say ~df[(*-3..*-1)]^;       # tail
#]

#`[
say "---------------------------------------------";
### DataFrame Operations ###
# 2d Map/Reduce
say df.map(*.map(*+2).eager);
say [+] df[*;1];
say [+] df[1;*];
say [+] df[*;*];
# Hyper
say df >>+>> 2;
say df >>+<< df;
# Transpose   #FIXME - rust not working
say ~df.T;                 
# Describe
say df.height;
say df.width;
say df.shape;
say df.series(<A>).show;
say ~df.describe;
say "---------------------------------------------";
# Sort
#say ~df.sort: { .[1] };         # sort by 2nd col (ascending)
df.sort( { .[1] } ).show;         # sort by 2nd col (ascending)
#say ~df.sort: { -.[1] };        # sort by 2nd col (descending)
df.sort( { -.[1] } ).show;         # sort by 2nd col (ascending)
##say ~df.sort: { df[$++]<C> };   # sort by col C  [FIXME cascade dead]
##say ~df.sort: { df.ix[$++] };   # sort by index 
df.sort( { df.ix[$++] } ).show;    # sort by index (no-op)
# Grep (binary filter)
#say ~df.grep( { .[1] < 0.5 } );   # by 2nd column 
df.grep( { .[1] < 0.5 } ).show;   # by 2nd column 
##say ~df.grep( { df.ix[$++] eq <2022-01-02 2022-01-06>.any } ); # by index (multiple) 
#]

#`[
say "---------------------------------------------";
#FIXME align dtype arg to Str (Dan & Dan::Pandas)
my \df2 = DataFrame.new([
        A => 1.0,
        B => Date.new("2022-01-01"),
        C => Series.new(1, index => [0..^4], dtype => 'Num'),
        D => [3 xx 4],
        E => Categorical.new(<test train test train>),
        F => "foo",
]);
##say ~df2;
df2.show;
say df2.data;
say df2.dtypes;
say df2.index;    #Hash (name => row number)   -or- df.ix; #Array
say df2.columns;  #Hash (label => col number)  -or- df.cx; #Array
#]

#`[
say "---------------------------------------------";
# row-wise splice:    #FIXME cant get a DataSlice
my $ds = df2[0];                        # get a DataSlice 
$ds.splice($ds.index<A>,1,7);           # tweak it a bit
df2.splice( 1, 2, [j => $ds] );         # default
# column-wise splice:
##my $se = df2[*]<D>;              	      # get a Series 
my $se = df2.series: <D>;               # get a Series 
$se.splice(2, 1, [2 => 8]);             # tweak it a bit
$se.show;
df2.splice( :ax, 1, 2, [K => $se] );    # axis => 1
df2.show;
#]

#`[[[ iamerejh
#[
my \dfa = DataFrame.new(
        [['a', 1], ['b', 2]],
        columns => <letter number>,
);
##say ~dfa;
dfa.show;
my \dfc = DataFrame.new(
        [['c', 3, 'cat'], ['d', 4, 'dog']],
        columns => <animal letter number>,
);
##say ~dfc;
dfc.show;
say "---------------------------------------------";
dfa.concat(dfc);
##say ~dfa;
dfa.show;
#]
#]]]
