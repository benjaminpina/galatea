export namespace common {
	
	export class PaginationResponse {
	    page: number;
	    page_size: number;
	    total_count: number;
	    total_pages: number;
	
	    static createFrom(source: any = {}) {
	        return new PaginationResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.page = source["page"];
	        this.page_size = source["page_size"];
	        this.total_count = source["total_count"];
	        this.total_pages = source["total_pages"];
	    }
	}

}

export namespace substrate {
	
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
	export class MixedSubstratePaginatedResponse {
	    data: MixedSubstrateResponse[];
	    pagination: common.PaginationResponse;
	
	    static createFrom(source: any = {}) {
	        return new MixedSubstratePaginatedResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.data = this.convertValues(source["data"], MixedSubstrateResponse);
	        this.pagination = this.convertValues(source["pagination"], common.PaginationResponse);
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
	export class PaginatedResponse {
	    data: SubstrateResponse[];
	    pagination: common.PaginationResponse;
	
	    static createFrom(source: any = {}) {
	        return new PaginatedResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.data = this.convertValues(source["data"], SubstrateResponse);
	        this.pagination = this.convertValues(source["pagination"], common.PaginationResponse);
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
	export class SubstrateSetPaginatedResponse {
	    data: SubstrateSetResponse[];
	    pagination: common.PaginationResponse;
	
	    static createFrom(source: any = {}) {
	        return new SubstrateSetPaginatedResponse(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.data = this.convertValues(source["data"], SubstrateSetResponse);
	        this.pagination = this.convertValues(source["pagination"], common.PaginationResponse);
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

}

