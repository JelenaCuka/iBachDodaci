//
//  DataSourceManager.swift
//  iBach
//
//  Created by Neven Travaš on 29/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation


class DataSourceManager {
    
    
    
    public func currentDataSource(selectedDatasourceType: DataSourceType) -> SongDetailDatasource {
        
        var datasource: SongDetailDatasource
        switch selectedDatasourceType {
        case .musicxmatch:
            datasource = MusicMatchSongDetailsDataSource()
        case .songLyrics:
            datasource = MusicMatchSongDetailsDataSource() // TODO: dok dodamo novi datasource promjeni klasu
        case .myLyrics:
            datasource = MusicMatchSongDetailsDataSource()
            
        
        case .songInfo:
            datasource = SongInfo()
        case .similarTracks:
            datasource = SimilarTracks()
        }
        return datasource
    }
}
