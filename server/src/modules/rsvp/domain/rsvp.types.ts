export enum RsvpStatus {
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
  WAITLIST = 'WAITLIST',
}

export interface IRsvp {
  id: string;
  userId: string;
  eventId: string;
  qrToken: string;
  status: RsvpStatus;
  createdAt: Date;
}

/** Flat response for GET /events/{id}/rsvp — includes user info for admin offline cache. */
export interface IRsvpWithUser extends IRsvp {
  user: {
    displayName: string;
    npa: string | null;
    cabang: string | null;
    photoUrl: string | null;
  };
}

export interface ICreateRsvpData {
  userId: string;
  eventId: string;
  qrToken: string;
}

export interface IRsvpFilter {
  page: number;
  limit: number;
}
