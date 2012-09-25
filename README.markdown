# Coverflow Implementation using UICollectionView

## What?

This is an iPhone project implementing Coverflow using iOS 6 UICollectionViews and a custom UICollectionViewLayout

Screenshot: [http://cloud.toxicsoftware.com/image/0z0N3A0e2b1l](http://cloud.toxicsoftware.com/image/0z0N3A0e2b1l)

View it in action here: [CollectionViewCoverFlow.mov](http://cloud.toxicsoftware.com/1120003t3N2Y)

Yes, Apple demoed this at WWDC but I think the interpolation technique I use is rather neat and allows you to easily adjust the layout and behavior of the layout.

## CInterpolator

CInterpolator objects are a little like CAKeyFrameAnimation objects except they're not necessarily time based. You can use them for (linear) key frame interpolation between any keys and values

## TODO

* Optimisation. Right now it is laying out _every_ cell. This is bad bad bad! (Easily fixed)
* Bounds calculation. It has a hardcoded width for the content bounds.
* The "Gloom" layer doesn't do a very good job with alpha backgrounds.
* Aliasing is very obvious on straight edges when rotation.
* Test on low end hardware.
* See how often interpolators are called with same the key - might be small Optimisation point?
