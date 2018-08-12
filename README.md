# Bianchi's model

This repository contains a Matlab/Octave script to study Bianchi's model for both IEEE 802.11n and 802.11ac standards.

## Quickstart

Modify the input parameters for the desired use case at the start of the script before running it:
``` matlab
%Change these parameters for the different simulations
standard = 'ac';                    %ac or n
frame_aggregation = true;           %true or false
guard = 'short';                     %short or long
```

Tested with GNU Octave, version 4.0.0

## Simulation

This model, presented by Giuseppe Bianchi in 2000's [paper](http://omikron.eit.lth.se/ETSN01/ETSN012015/papers/bianchi2000performance.pdf), evaluates the performance of Medium Access Control (MAC) techniques of 802.11 networks. It is a simple analytical model that can be used to calculate the saturation throughput in ideal channel conditions with accurate results.

Each station is characterized as a Markov model that will transmit in a randomly chosen slot time with a stationary probability `τ`. This probability does not depend on the access mechanism employed. The throughput formula can be derived upon the events that may occur within a given slot time and will be a function of `τ`. 

For the scalability studio, the number of stations will be increased from 1 to 500 in 10-user steps, being this variable named `N`. The standards studied will be IEEE 802.11ac (transmission in the 5GHz band) and 802.11n (2.4GHz band). Each of them has a set of mandatory MCS which are used to determine the data rate of a wireless connection.

The code was implemented for all different combinations: 802.11ac and 802.11n, with and without frame aggregation and, finally, with either short or long guard intervals. For each possible scenario we present two plots: the left one shows the throughput versus the number of users for a given payload of 1500 Bytes; the right one yields the throughput against the payload size for the ideal case (only one user transmitting). In the cases where frame aggregation is considered we assume that the number of
aggregated frames used will be the maximum that fulfills all the requirements (in terms of frames, data length and time).

## Results

As expected, the ideal case is when no collision is possible, i.e. one transmitting user. When the number of users increases, overall performance is degraded due to resource contention and CSMA/CA limitations. Decay pattern is similar across all cases but throughput is much greater when aggregating frames.

Upon payload size increase we obtain a higher throughput efficiency, approaching the theoretical limit. If we use frame aggregation, the gain for a higher payload is not as significant and starts to stagnate for medium payload sizes, as
the data length already dominates against the access control information. Both the duration of the guard interval and specification used (except for the added mandatory MCS) have a more subtle effect in the curves and efficiency loss table.

The resulting figures, for each scenario, are:

* 802.11n, short guard interval, no frame aggregation

![img1](https://user-images.githubusercontent.com/29493411/43610543-b7311ec2-96a6-11e8-8e5c-13beb3f884be.png)

* 802.11n, long guard interval, no frame aggregation

![img2](https://user-images.githubusercontent.com/29493411/43610544-b75a3758-96a6-11e8-9977-15a206a957da.png)

* 802.11n, short guard interval, frame aggregation

![img3](https://user-images.githubusercontent.com/29493411/43610545-b7750f92-96a6-11e8-8671-05c07049cd38.png)

* 802.11n, long guard interval, frame aggregation

![img4](https://user-images.githubusercontent.com/29493411/43610546-b790aa5e-96a6-11e8-9f14-c753a84fd9d6.png)

* 802.11ac, short guard interval, no frame aggregation

![img5](https://user-images.githubusercontent.com/29493411/43610547-b7ac365c-96a6-11e8-810c-ae15e30242ad.png)

* 802.11ac, long guard interval, no frame aggregation

![img6](https://user-images.githubusercontent.com/29493411/43610548-b7c90bf6-96a6-11e8-8387-d9c8158ae66f.png)

* 802.11ac, short guard interval, frame aggregation

![img7](https://user-images.githubusercontent.com/29493411/43610549-b7e62768-96a6-11e8-80ee-1d9229cf4410.png)

* 802.11ac, long guard interval, frame aggregation

![img8](https://user-images.githubusercontent.com/29493411/43610550-b800ed1e-96a6-11e8-9c82-b1d82f7a1e5c.png)

We can also calculate the loss of efficiency with the previously obtained thorughput results for each case. Frame aggregation and long data sizes can be used to minimize the losses due to the access mechanism.

* Loss of efficiency (MCS 0):

![loss0](https://user-images.githubusercontent.com/29493411/43610551-b81b2260-96a6-11e8-9888-96c6df190196.png)

* Loss of efficiency (MCS 7):

![loss7](https://user-images.githubusercontent.com/29493411/43610552-b8380e52-96a6-11e8-814e-f8fed6dd21d9.png)

## Conclusions

* The main goal is to demonstrate the usefulness of Bianchi’s model for throughput calculations.
* Access mechanism is one of the main bottlenecks of current Wi-Fi specifications.
* However, frame aggregation and high payload sizes mitigate throughput losses.

## License

This example is porvided under the MIT License.

## Issues

Report any issue to the GitHub issue tracker.
