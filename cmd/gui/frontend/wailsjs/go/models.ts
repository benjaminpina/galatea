export namespace substrate {
	
	export class MixedSubstrateRequest {
	    id: string;
	    name: string;
	    color: string;
	
	    static createFrom(source: any = {}) {
	        return new MixedSubstrateRequest(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.color = source["color"];
	    }
	}
	export class SubstratePercentageResponse {
	    substrate_id: string;
	    substrate_name: string;
	    color: string;
	    percentage: number;
	
	    static createFrom(source: any = {}) {
	        return new SubstratePercentageResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.substrate_id = source["substrate_id"];
	        this.substrate_name = source["substrate_name"];
	        this.color = source["color"];
	        this.percentage = source["percentage"];
	    }
	}
	export class MixedSubstrateResponse {
	    id: string;
	    name: string;
	    color: string;
	    substrates: SubstratePercentageResponse[];
	
	    static createFrom(source: any = {}) {
	        return new MixedSubstrateResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.color = source["color"];
	        this.substrates = this.convertValues(source["substrates"], SubstratePercentageResponse);
	    }
	
		convertValues(a: any, classs: any, asMap: boolean = false): any {
		    if (!a) {
		        return a;
		    }
		    if (a.slice && a.map) {
		        return (a as any[]).map(elem => this.convertValues(elem, classs));
		    } else if ("object" === typeof a) {
		        if (asMap) {
		            for (const key of Object.keys(a)) {
		                a[key] = new classs(a[key]);
		            }
		            return a;
		        }
		        return new classs(a);
		    }
		    return a;
		}
	}
	export class SubstratePercentageRequest {
	    substrate_id: string;
	    percentage: number;
	
	    static createFrom(source: any = {}) {
	        return new SubstratePercentageRequest(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.substrate_id = source["substrate_id"];
	        this.percentage = source["percentage"];
	    }
	}
	
	export class SubstrateRequest {
	    id: string;
	    name: string;
	    color: string;
	
	    static createFrom(source: any = {}) {
	        return new SubstrateRequest(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.color = source["color"];
	    }
	}
	export class SubstrateResponse {
	    id: string;
	    name: string;
	    color: string;
	
	    static createFrom(source: any = {}) {
	        return new SubstrateResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.color = source["color"];
	    }
	}
	export class SubstrateSetRequest {
	    id: string;
	    name: string;
	
	    static createFrom(source: any = {}) {
	        return new SubstrateSetRequest(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	    }
	}
	export class SubstrateSetResponse {
	    id: string;
	    name: string;
	    substrates: SubstrateResponse[];
	    mixed_substrates: MixedSubstrateResponse[];
	
	    static createFrom(source: any = {}) {
	        return new SubstrateSetResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.substrates = this.convertValues(source["substrates"], SubstrateResponse);
	        this.mixed_substrates = this.convertValues(source["mixed_substrates"], MixedSubstrateResponse);
	    }
	
		convertValues(a: any, classs: any, asMap: boolean = false): any {
		    if (!a) {
		        return a;
		    }
		    if (a.slice && a.map) {
		        return (a as any[]).map(elem => this.convertValues(elem, classs));
		    } else if ("object" === typeof a) {
		        if (asMap) {
		            for (const key of Object.keys(a)) {
		                a[key] = new classs(a[key]);
		            }
		            return a;
		        }
		        return new classs(a);
		    }
		    return a;
		}
	}

}

