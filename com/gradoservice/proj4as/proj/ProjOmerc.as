/*******************************************************************************
NAME                       OBLIQUE MERCATOR (HOTINE) 

PURPOSE:	Transforms input longitude and latitude to Easting and
		Northing for the Oblique Mercator projection.  The
		longitude and latitude must be in radians.  The Easting
		and Northing values will be returned in meters.

PROGRAMMER              DATE
----------              ----
T. Mittan		Mar, 1993

ALGORITHM REFERENCES

1.  Snyder, John P., "Map Projections--A Working Manual", U.S. Geological
    Survey Professional Paper 1395 (Supersedes USGS Bulletin 1532), United
    State Government Printing Office, Washington D.C., 1987.

2.  Snyder, John P. and Voxland, Philip M., "An Album of Map Projections",
    U.S. Geological Survey Professional Paper 1453 , United State Government
    Printing Office, Washington D.C., 1989.
*******************************************************************************/

package com.gradoservice.proj4as.proj
{
	import com.gradoservice.proj4as.ProjPoint;
	import com.gradoservice.proj4as.ProjConstants;
	import com.gradoservice.proj4as.Datum;
		
	public class ProjOmerc extends AbstractProjProjection
	{
		private var d:Number;		
		private var f:Number;		
		private var h:Number;		
		private var j:Number;		
		private var l:Number;	
		private var p:Number;	
		private var u:Number;		
		private var dlon:Number;		
		private var al:Number;
		private var bl:Number;		
		private var el:Number;		
		private var com:Number;		
		private var cos_p20:Number;		
		private var cosaz:Number;		
		private var cosgam:Number;		
		private var at1:Number;		
		private var gam:Number;		
		private var gama:Number;
		private var lon1:Number;
		private var lon2:Number;
		private var sin_p20:Number;				 		
		private var sinaz:Number;	
		private var singam:Number;		
		private var ts:Number;		
		private var ts1:Number;		
		private var ts2:Number;		
		
		public function ProjOmerc(data:ProjParams)
		{
			super(data);
		}
		
		
		  override public function init():void
		  {
		    if (!this.mode) this.mode=0;
		    if (!this.lon1)   {this.lon1=0;this.mode=1;}
		    if (!this.lon2)   this.lon2=0;
		    if (!this.lat2)    this.lat2=0;
		
		    /* Place parameters in static storage for common use
		      -------------------------------------------------*/
		    var temp:Number = this.b/ this.a;
		    var es:Number = 1.0 - Math.pow(temp,2);
		    var e:Number = Math.sqrt(es);
		
		    this.sin_p20=Math.sin(this.lat0);
		    this.cos_p20=Math.cos(this.lat0);
		
		    this.con = 1.0 - this.es * this.sin_p20 * this.sin_p20;
		    this.com = Math.sqrt(1.0 - es);
		    this.bl = Math.sqrt(1.0 + this.es * Math.pow(this.cos_p20,4.0)/(1.0 - es));
		    this.al = this.a * this.bl * this.k0 * this.com / this.con;
		    if (Math.abs(this.lat0) < ProjConstants.EPSLN) {
		       this.ts = 1.0;
		       this.d = 1.0;
		       this.el = 1.0;
		    } else {
		       this.ts = ProjConstants.tsfnz(this.e,this.lat0,this.sin_p20);
		       this.con = Math.sqrt(this.con);
		       this.d = this.bl * this.com / (this.cos_p20 * this.con);
		       if ((this.d * this.d - 1.0) > 0.0) {
		          if (this.lat0 >= 0.0) {
		             this.f = this.d + Math.sqrt(this.d * this.d - 1.0);
		          } else {
		             this.f = this.d - Math.sqrt(this.d * this.d - 1.0);
		          }
		       } else {
		         this.f = this.d;
		       }
		       this.el = this.f * Math.pow(this.ts,this.bl);
		    }
		
		    //this.longc=52.60353916666667;
		
		    if (this.mode != 0) {
		       this.g = .5 * (this.f - 1.0/this.f);
		       this.gama = ProjConstants.asinz(Math.sin(this.alpha) / this.d);
		       this.longc= this.longc - ProjConstants.asinz(this.g * Math.tan(this.gama))/this.bl;
		
		       /* Report parameters common to format B
		       -------------------------------------*/
		       //genrpt(azimuth * R2D,"Azimuth of Central Line:    ");
		       //cenlon(lon_origin);
		      // cenlat(lat_origin);
		
		       this.con = Math.abs(this.lat0);
		       if ((this.con > ProjConstants.EPSLN) && (Math.abs(this.con - ProjConstants.HALF_PI) > ProjConstants.EPSLN)) {
		            this.singam=Math.sin(this.gama);
		            this.cosgam=Math.cos(this.gama);
		
		            this.sinaz=Math.sin(this.alpha);
		            this.cosaz=Math.cos(this.alpha);
		
		            if (this.lat0>= 0) {
		               this.u =  (this.al / this.bl) * Math.atan(Math.sqrt(this.d*this.d - 1.0)/this.cosaz);
		            } else {
		               this.u =  -(this.al / this.bl) *Math.atan(Math.sqrt(this.d*this.d - 1.0)/this.cosaz);
		            }
		          } else {
		            trace("omerc:Init:DataError");
		          }
		       } else {
		       this.sinphi =Math. sin(this.at1);
		       this.ts1 = ProjConstants.tsfnz(this.e,this.lat1,this.sinphi);
		       this.sinphi = Math.sin(this.lat2);
		       this.ts2 = ProjConstants.tsfnz(this.e,this.lat2,this.sinphi);
		       this.h = Math.pow(this.ts1,this.bl);
		       this.l = Math.pow(this.ts2,this.bl);
		       this.f = this.el/this.h;
		       this.g = .5 * (this.f - 1.0/this.f);
		       this.j = (this.el * this.el - this.l * this.h)/(this.el * this.el + this.l * this.h);
		       this.p = (this.l - this.h) / (this.l + this.h);
		       this.dlon = this.lon1 - this.lon2;
		       if (this.dlon < -ProjConstants.PI) this.lon2 = this.lon2 - 2.0 * ProjConstants.PI;
		       if (this.dlon > ProjConstants.PI) this.lon2 = this.lon2 + 2.0 * ProjConstants.PI;
		       this.dlon = this.lon1 - this.lon2;
		       this.longc = .5 * (this.lon1 + this.lon2) -Math.atan(this.j * Math.tan(.5 * this.bl * this.dlon)/this.p)/this.bl;
		       this.dlon  = ProjConstants.adjust_lon(this.lon1 - this.longc);
		       this.gama = Math.atan(Math.sin(this.bl * this.dlon)/this.g);
		       this.alpha = ProjConstants.asinz(this.d * Math.sin(this.gama));
		
		       /* Report parameters common to format A
		       -------------------------------------*/
		
		       if (Math.abs(this.lat1 - this.lat2) <= ProjConstants.EPSLN) {
		          trace("omercInitDataError");
		          //return(202);
		       } else {
		          this.con = Math.abs(this.lat1);
		       }
		       if ((this.con <= ProjConstants.EPSLN) || (Math.abs(this.con - ProjConstants.HALF_PI) <= ProjConstants.EPSLN)) {
		           trace("omercInitDataError");
		                //return(202);
		       } else {
		         if (Math.abs(Math.abs(this.lat0) - ProjConstants.HALF_PI) <= ProjConstants.EPSLN) {
		            trace("omercInitDataError");
		            //return(202);
		         }
		       }
		
		       this.singam=Math.sin(this.gam);
		       this.cosgam=Math.cos(this.gam);
		
		       this.sinaz=Math.sin(this.alpha);
		       this.cosaz=Math.cos(this.alpha);  
		
		
		       if (this.lat0 >= 0) {
		          this.u =  (this.al/this.bl) * Math.atan(Math.sqrt(this.d * this.d - 1.0)/this.cosaz);
		       } else {
		          this.u = -(this.al/this.bl) * Math.atan(Math.sqrt(this.d * this.d - 1.0)/this.cosaz);
		       }
		     }
		  }
		
		
		  /* Oblique Mercator forward equations--mapping lat,long to x,y
		    ----------------------------------------------------------*/
		  override public function forward(p:ProjPoint):ProjPoint
		  {
		    var theta:Number;		/* angle					*/
		    var sin_phi:Number, cos_phi:Number;/* sin and cos value				*/
		    var b:Number;		/* temporary values				*/
		    var c:Number, t:Number, tq:Number;	/* temporary values				*/
		    var con:Number, n:Number, ml:Number;	/* cone constant, small m			*/
		    var q:Number,us:Number,vl:Number;
		    var ul:Number,vs:Number;
		    var s:Number;
		    var dlon:Number;
		    var ts1:Number;
		
		    var lon:Number=p.x;
		    var lat:Number=p.y;
		    /* Forward equations
		      -----------------*/
		    sin_phi = Math.sin(lat);
		    dlon = ProjConstants.adjust_lon(lon - this.longc);
		    vl = Math.sin(this.bl * dlon);
		    if (Math.abs(Math.abs(lat) - ProjConstants.HALF_PI) > ProjConstants.EPSLN) {
		       ts1 = ProjConstants.tsfnz(this.e,lat,sin_phi);
		       q = this.el / (Math.pow(ts1,this.bl));
		       s = .5 * (q - 1.0 / q);
		       t = .5 * (q + 1.0/ q);
		       ul = (s * this.singam - vl * this.cosgam) / t;
		       con = Math.cos(this.bl * dlon);
		       if (Math.abs(con) < .0000001) {
		          us = this.al * this.bl * dlon;
		       } else {
		          us = this.al * Math.atan((s * this.cosgam + vl * this.singam) / con)/this.bl;
		          if (con < 0) us = us + ProjConstants.PI * this.al / this.bl;
		       }
		    } else {
		       if (lat >= 0) {
		          ul = this.singam;
		       } else {
		          ul = -this.singam;
		       }
		       us = this.al * lat / this.bl;
		    }
		    if (Math.abs(Math.abs(ul) - 1.0) <= ProjConstants.EPSLN) {
		       //alert("Point projects into infinity","omer-for");
		       trace("omercFwdInfinity");
		       //return(205);
		    }
		    vs = .5 * this.al * Math.log((1.0 - ul)/(1.0 + ul)) / this.bl;
		    us = us - this.u;
		    var x:Number = this.x0 + vs * this.cosaz + us * this.sinaz;
		    var y:Number = this.y0 + us * this.cosaz - vs * this.sinaz;
		
		    p.x=x;
		    p.y=y;
		    return p;
		  }
		
		 override public function inverse(p:ProjPoint):ProjPoint
		 {
		    var delta_lon:Number;	/* Delta longitude (Given longitude - center 	*/
		    var theta:Number;		/* angle					*/
		    var delta_theta:Number;	/* adjusted longitude				*/
		    var sin_phi:Number, cos_phi:Number;/* sin and cos value				*/
		    var b:Number;		/* temporary values				*/
		    var c:Number, t:Number, tq:Number;	/* temporary values				*/
		    var con:Number, n:Number, ml:Number;	/* cone constant, small m			*/
		    var vs:Number,us:Number,q:Number,s:Number,ts1:Number;
		    var vl:Number,ul:Number,bs:Number;
		    var dlon:Number;
		    var  flag:Number;
		
		    /* Inverse equations
		      -----------------*/
		    p.x -= this.x0;
		    p.y -= this.y0;
		    flag = 0;
		    vs = p.x * this.cosaz - p.y * this.sinaz;
		    us = p.y * this.cosaz + p.x * this.sinaz;
		    us = us + this.u;
		    q = Math.exp(-this.bl * vs / this.al);
		    s = .5 * (q - 1.0/q);
		    t = .5 * (q + 1.0/q);
		    vl = Math.sin(this.bl * us / this.al);
		    ul = (vl * this.cosgam + s * this.singam)/t;
		    if (Math.abs(Math.abs(ul) - 1.0) <= ProjConstants.EPSLN)
		       {
		       var lon:Number = this.longc;
		       if (ul >= 0.0) {
		          var lat:Number = ProjConstants.HALF_PI;
		       } else {
		         lat = -ProjConstants.HALF_PI;
		       }
		    } else {
		       con = 1.0 / this.bl;
		       ts1 =Math.pow((this.el / Math.sqrt((1.0 + ul) / (1.0 - ul))),con);
		       lat = ProjConstants.phi2z(this.e,ts1);
		       //if (flag != 0)
		          //return(flag);
		       //~ con = Math.cos(this.bl * us /al);
		       theta = this.longc - Math.atan2((s * this.cosgam - vl * this.singam) , con)/this.bl;
		       lon = ProjConstants.adjust_lon(theta);
		    }
		    p.x=lon;
		    p.y=lat;
		    return p;
		  }
		
		
	}
}