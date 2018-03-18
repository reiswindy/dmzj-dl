# dmzj-dl

Tool for downloading manhua

## Installation

```
git clone git@github.com:reiswindy/dmzj-dl.git
cd dmzj-dl
shards build --production
```

## Usage

List chapters of a manhua
```shell
$ ./dmzj chapters <manhua>
```

Output is `<chapter_index> - <chapter_title> <upload date>`

Example:
```shell
$ ./dmzj chapters liuzhuanyueguang
Fetching information...
0 - 流转钥光第01话危险的钥匙 2018-03-13
1 - 流转钥光第02话 一半的光明 2018-03-15
```

Download chapter using the chapter_index
```shell
$ ./dmzj download <manhua> <chapter_index>
```

Example:
```shell
$ ./dmzj download musexunxiang 0
```

## Contributors

- [reiswindy](https://github.com/reiswindy) - creator