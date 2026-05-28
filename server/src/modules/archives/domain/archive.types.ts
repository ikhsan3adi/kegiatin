export enum ArchiveType {
  MATERIAL = 'MATERIAL',
  PHOTO = 'PHOTO',
  EVALUATION = 'EVALUATION',
}

export interface IArchive {
  id: string;
  sessionId: string;
  title: string;
  type: ArchiveType;
  fileUrl: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ICreateArchiveData {
  title: string;
  type: ArchiveType;
  fileUrl: string;
  sessionId: string;
}
