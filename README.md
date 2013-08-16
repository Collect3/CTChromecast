# CTChromecast
`CTChromecast` is a collection of classes to make integrating Chromecast support into an existing iOS video player easier. 

`CTChromecastMoviePlayerController` provides a drop in replacement for `MPMoviePlayerController` to support casting videos to Chromecast

## Usage

Creation of a movie player can be done in the same way a MPMoviePlayerController is used

```objective-c
CTChromecastMoviePlayerController *player = [[CTChromecastMoviePlayerController alloc] initWithContentURL: url];
player.view.frame = self.view.bounds;
[self.view addSubview: player.view];    
[player play];
````

When chromecast device(s) are detected a button allowing for device selection will be shown along side the volume sider

<p align="center" >
  <img src="https://raw.github.com/Collect3/CTChromecast/screenshots/chromecast-example.png" alt="Example" title="Example">
</p>

## Demo

Build and run the `Example` project in Xcode to see a demo movie player.


## Limitations
* Currently does not support playing local files

## Contact

[David Fumberger](http://github.com/djfumberger)
[@djfumberger](https://twitter.com/djfumberger)

## License
CTChromecast is available under the MIT license. See the LICENSE file for more info.